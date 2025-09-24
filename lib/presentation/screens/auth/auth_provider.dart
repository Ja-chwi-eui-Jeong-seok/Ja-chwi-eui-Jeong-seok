import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/auth_datasource.dart';
import 'package:ja_chwi/data/datasources/auth_datasource_impl.dart';
import 'package:ja_chwi/domain/usecases/auth_usecase.dart';
import 'auth_view_model.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
  );
  return AuthNotifier(
    googleUseCase: SignInWithGoogleUseCase(repository),
    appleUseCase: SignInWithAppleUseCase(repository),
    updateUserUseCase: UpdateUserUseCase(repository),
  );
});
