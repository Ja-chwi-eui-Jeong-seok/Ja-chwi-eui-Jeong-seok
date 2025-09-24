import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/auth_model.dart';
import '../../domain/entities/auth_entity.dart';

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

  static const String kAuthCollection = 'auth';

  Future<String> _getDeviceName() async {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'unknown';
  }

  @override
  Future<AuthModel?> signInWithGoogle() async {
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
      if (!snapshot.exists) {
        print('신규 유저 Firestore 저장: ${newUser.toMap()}');
      } else {
        print('기존 유저 Firestore 데이터 불러옴: ${snapshot.data()}');
      }
      await docRef.set(newUser.toMap());
      return newUser;
    } else {
      return AuthModel.fromMap(snapshot.data()!, snapshot.id);
    }
  }

  @override
  Future<AuthModel?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCred = await _auth.signInWithCredential(oauthCredential);
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
