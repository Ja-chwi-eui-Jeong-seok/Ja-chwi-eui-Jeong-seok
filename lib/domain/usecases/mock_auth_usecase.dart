import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ja_chwi/data/datasources/auth_datasource.dart';
import 'package:ja_chwi/data/models/auth_model.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';

abstract class AppleLoginUseCase {
  Future<AuthEntity?> execute();
}

class AppleLoginUseCaseImpl implements AppleLoginUseCase {
  final AuthDataSource dataSource;

  AppleLoginUseCaseImpl(this.dataSource);

  @override
  Future<AuthEntity?> execute() async {
    if (Platform.isIOS && !kIsWeb) {
      // 실제 iOS 기기에서만 Apple 로그인
      return await dataSource.signInWithApple();
    } else {
      // Simulator, Android, Web에서는 Mock 로그인
      return _mockSignIn();
    }
  }

  AuthModel _mockSignIn() {
    // 테스트용 가짜 사용자
    return AuthModel(
      uid: 'mock_apple_user',
      accountData: 'Apple Mock User',
      accountEmail: 'mock@apple.com',
      accountType: 'apple',
      createDevice: 'Simulator',
      privacyConsent: true,
      agreeToTermsOfService: true,
      userCreateDate: DateTime.now(),
      userUpdateDate: DateTime.now(),
      userDeleteDate: null,
      userDeleteNote: '',
      managerType: false,
    );
  }
}
