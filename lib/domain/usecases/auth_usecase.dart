import 'package:ja_chwi/domain/entities/auth_entity.dart';
import 'package:ja_chwi/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<AuthEntity?> execute() => repository.signInWithGoogle();
}

class SignInWithAppleUseCase {
  final AuthRepository repository;
  SignInWithAppleUseCase(this.repository);

  Future<AuthEntity?> execute() => repository.signInWithApple();
}

class UpdateUserUseCase {
  final AuthRepository repository;
  UpdateUserUseCase(this.repository);

  Future<void> execute(AuthEntity entity) => repository.updateUser(entity);
}
