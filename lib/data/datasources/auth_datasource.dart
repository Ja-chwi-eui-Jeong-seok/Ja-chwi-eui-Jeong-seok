import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/auth_model.dart';
import '../../domain/entities/auth_entity.dart';
import 'dart:convert'; // utf8
import 'dart:math'; // Random
import 'package:crypto/crypto.dart'; // sha256

abstract class AuthDataSource {
  Future<AuthEntity?> signInWithGoogle();
  Future<AuthEntity?> signInWithApple();
  Future<AuthEntity?> fetchCurrentUser();
  Future<void> signOut();
  Future<void> updateUser(AuthModel user);
  Future<void> softDeleteUser(String uid, {String? reason});
}

class AuthRemoteDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static const String kAuthCollection = 'user_profile';

  Future<String> _getDeviceName() async {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'unknown';
  }

  @override
  Future<AuthModel?> signInWithGoogle() async {
    // 항상 계정 선택창을 표시하기 위해 기존 로그인을 해제합니다.
    // 이전에 로그인한 사용자가 있으면 silent sign-in이 되어 계정 선택창이 뜨지 않는 것을 방지합니다.
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _auth.signInWithCredential(credential);

    final user = userCred.user;

    if (user == null) return null;
    final docRef = _firestore.collection(kAuthCollection).doc(user.uid);

    final snapshot = await docRef.get();

    final deviceName = await _getDeviceName();

    if (!snapshot.exists) {
      final newUser = AuthModel(
        uid: user.uid,
        accountData: user.displayName ?? '',
        accountEmail: user.email ?? '',
        accountType: 'google',
        createDevice: deviceName,
        privacyConsent: true,
        agreeToTermsOfService: true,
        userCreateDate: DateTime.now(),
        userUpdateDate: DateTime.now(),
        userDeleteDate: null,
        userDeleteNote: '',
        managerType: false,
      );

      print('로그인 성공: ${user.email}');
      print('신규 유저 Firestore 저장: ${newUser.toMap()}'); // 신규 유저 정보 출력
      try {
        await docRef.set(newUser.toMap());
        print("✅ Firestore 저장 성공 (uid: ${user.uid})");
      } catch (e) {
        print("❌ Firestore 저장 실패: $e");
      }
      return newUser;
    } else {
      // 기존 유저인 경우 Firestore에서 데이터를 불러옴
      return AuthModel.fromMap(snapshot.data()!, snapshot.id);
    }
  }

  @override
  Future<AuthModel?> signInWithApple() async {
    // 1. rawNonce & hashedNonce 생성
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    // 2. Apple 로그인 요청 (hashedNonce 전달)
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    // 3. Firebase OAuthCredential 생성 (idToken + rawNonce)
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // 4. Firebase Auth 로그인
    final userCred = await _auth.signInWithCredential(oauthCredential);
    final user = userCred.user;
    if (user == null) return null;

    // 5. Firestore 사용자 문서 처리
    final docRef = _firestore.collection(kAuthCollection).doc(user.uid);
    final snapshot = await docRef.get();
    final deviceName = await _getDeviceName();

    if (!snapshot.exists) {
      final newUser = AuthModel(
        uid: user.uid,
        accountData: user.displayName ?? '',
        accountEmail: user.email ?? '',
        accountType: 'apple',
        createDevice: deviceName,
        privacyConsent: true,
        agreeToTermsOfService: true,
        userCreateDate: DateTime.now(),
        userUpdateDate: DateTime.now(),
        userDeleteDate: null,
        userDeleteNote: '',
        managerType: false,
      );
      print('Firestore 저장 데이터: ${newUser.toMap()}');
      await docRef.set(newUser.toMap());
      return newUser;
    } else {
      return AuthModel.fromMap(snapshot.data()!, snapshot.id);
    }
  }

  /// 🔐 nonce 생성 유틸
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<AuthModel?> fetchCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection(kAuthCollection)
        .doc(user.uid)
        .get();
    if (!snapshot.exists) return null;

    return AuthModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> updateUser(AuthModel user) async {
    final docRef = _firestore.collection(kAuthCollection).doc(user.uid);
    await docRef.update(user.toMap());
  }

  @override
  Future<void> softDeleteUser(String uid, {String? reason}) async {
    final docRef = _firestore.collection(kAuthCollection).doc(uid);
    await docRef.update({
      'user_delete_date': DateTime.now(),
      'user_delete_note': reason ?? '사용자 요청',
    });
  }
}
