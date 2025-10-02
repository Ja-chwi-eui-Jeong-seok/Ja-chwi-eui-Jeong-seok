import 'package:ja_chwi/data/datasources/auth_datasource.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';
import 'package:ja_chwi/domain/repositories/auth_repository.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthEntity?> signInWithGoogle() async {
    final model = await remoteDataSource.signInWithGoogle();
    if (model is AuthModel) {
      return model.toDomain();
    }
    return model;
  }

  @override
  Future<AuthEntity?> signInWithApple() async {
    final model = await remoteDataSource.signInWithApple();
    if (model == null) return null;
    if (model is AuthModel) return model.toDomain();
    return model;
  }

  @override
  Future<AuthEntity?> getCurrentUser() async {
    final model = await remoteDataSource.fetchCurrentUser();
    if (model == null) return null;
    if (model is AuthModel) return model.toDomain();
    return model;
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<void> updateUser(AuthEntity entity) async {
    final model = AuthModel.fromDomain(entity);
    await remoteDataSource.updateUser(model);
  }

  @override
  Future<void> deleteUser(String userId, {String? reason}) async {
    await remoteDataSource.softDeleteUser(userId, reason: reason);
  }
}
