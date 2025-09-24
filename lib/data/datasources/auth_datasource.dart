import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ja_chwi/data/models/auth_model.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';

abstract class AuthDataSource {
  Future<AuthEntity?> signInWithGoogle();
  Future<AuthEntity?> signInWithApple();
  Future<AuthEntity?> fetchCurrentUser();
  Future<void> signOut();
  Future<void> updateUser(AuthModel user);
  Future<void> softDeleteUser(String userId, {String? reason});
}

class AuthRemoteDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> _getDeviceName() async {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    }
    return 'unknown';
  }

  @override
  Future<AuthModel?> signInWithGoogle() async {
    /* 구글 로그인 + Firestore 신규 계정 처리 */
  }
  @override
  Future<AuthModel?> signInWithApple() async {
    /* 애플 로그인 + Firestore 신규 계정 처리 */
  }
  @override
  Future<AuthModel?> fetchCurrentUser() async {
    /* 현재 로그인 사용자 가져오기 */
  }
  @override
  Future<void> signOut() async {
    /* 구글/파이어베이스 로그아웃 */
  }
  @override
  Future<void> updateUser(AuthModel user) async {
    /* Firestore 업데이트 */
  }
  @override
  Future<void> softDeleteUser(String userId, {String? reason}) async {
    /* 소프트 삭제 */
  }
}
