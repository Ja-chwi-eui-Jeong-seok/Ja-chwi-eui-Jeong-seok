import 'package:ja_chwi/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity?> signInWithGoogle();
  Future<AuthEntity?> signInWithApple();
  Future<AuthEntity?> getCurrentUser();
  Future<void> signOut();
  Future<void> updateUser(AuthEntity entity);
  Future<void> deleteUser(String accountData, {String? reason});
}
