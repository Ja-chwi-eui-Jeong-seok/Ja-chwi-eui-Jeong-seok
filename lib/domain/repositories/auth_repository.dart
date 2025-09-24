import 'package:ja_chwi/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity?> signInWithGoogle();
  Future<AuthEntity?> signInWithApple();
  Future<void> signOut();
  Future<AuthEntity?> getCurrentUser();
  Future<void> updateUser(AuthEntity user);
  Future<void> deleteUser(String userId, {String? reason});
}
