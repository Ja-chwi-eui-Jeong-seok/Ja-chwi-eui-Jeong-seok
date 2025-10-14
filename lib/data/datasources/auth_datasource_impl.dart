import 'package:ja_chwi/data/datasources/auth_datasource.dart';
import 'package:ja_chwi/data/models/auth_model.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';
import 'package:ja_chwi/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthEntity?> signInWithGoogle() async =>
      (await remoteDataSource.signInWithGoogle());

  @override
  Future<AuthEntity?> signInWithApple() async =>
      (await remoteDataSource.signInWithApple());
  @override
  Future<AuthEntity?> getCurrentUser() async =>
      (await remoteDataSource.fetchCurrentUser());
  @override
  Future<void> signOut() async => remoteDataSource.signOut();
  @override
  Future<void> updateUser(AuthEntity entity) async =>
      remoteDataSource.updateUser(AuthModel.fromDomain(entity));
  @override
  Future<void> deleteUser(String userId, {String? reason}) async =>
      remoteDataSource.softDeleteUser(userId, reason: reason);

  @override
  Future<void> deleteUserAccount(String uid, {String? reason}) async =>
      remoteDataSource.deleteUserAccount(uid, reason: reason);
}
