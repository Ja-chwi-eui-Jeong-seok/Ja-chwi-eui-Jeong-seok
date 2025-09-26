import 'package:ja_chwi/data/models/auth_model.dart';

abstract class AuthMockDataSource {
  Future<AuthModel?> signInWithGoogle();
  Future<AuthModel?> signInWithApple();
}

class AuthMockDataSourceImpl implements AuthMockDataSource {
  @override
  Future<AuthModel?> signInWithGoogle() async {
    // 시뮬레이터용 가짜 Google 사용자
    await Future.delayed(const Duration(milliseconds: 500)); // 로그인 지연 모방
    return AuthModel(
      uid: 'mock_google_user',
      accountData: 'Google Mock User',
      accountEmail: 'mock@gmail.com',
      accountType: 'google',
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

  @override
  Future<AuthModel?> signInWithApple() async {
    // 시뮬레이터용 가짜 Apple 사용자
    await Future.delayed(const Duration(milliseconds: 500));
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
