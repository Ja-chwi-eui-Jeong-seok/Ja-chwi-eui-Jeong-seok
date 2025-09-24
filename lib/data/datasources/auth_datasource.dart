import 'package:ja_chwi/domain/entities/auth_entity.dart';

abstract class AuthDataSource {
  Future<AuthEntity?> signInWithGoogle();
  Future<AuthEntity?> signInWithApple();
  Future<AuthEntity?> fetchCurrentUser();
  Future<void> signOut();
  Future<void> updateUser(AuthEntity user);
  Future<void> softDeleteUser(String userId, {String? reason});
}
