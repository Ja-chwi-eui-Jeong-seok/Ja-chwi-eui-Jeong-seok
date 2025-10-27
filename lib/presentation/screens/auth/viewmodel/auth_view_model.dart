import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';
import 'package:ja_chwi/domain/usecases/auth_usecase.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthEntity? user;
  final AuthStatus status;
  final String errorMessage;

  AuthState({this.user, this.status = AuthStatus.idle, this.errorMessage = ''});

  AuthState copyWith({
    AuthEntity? user,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithGoogleUseCase googleUseCase;
  final SignInWithAppleUseCase appleUseCase;
  final UpdateUserUseCase updateUserUseCase;

  AuthNotifier({
    required this.googleUseCase,
    required this.appleUseCase,
    required this.updateUserUseCase,
  }) : super(AuthState());

  Future<void> _signInWithProvider(
    Future<AuthEntity?> Function() loginFn,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await loginFn();
      if (user == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: "사용자 정보 없음",
        );
        return;
      }
      state = state.copyWith(user: user, status: AuthStatus.success);
    } catch (e) {
      String errorMessage = "로그인 중 오류가 발생했습니다.";

      if (e.toString().contains('user-not-found')) {
        errorMessage = "등록되지 않은 사용자입니다. 다시 로그인해주세요.";
      } else if (e.toString().contains('invalid-credential')) {
        errorMessage = "인증 정보가 올바르지 않습니다.";
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = "네트워크 연결을 확인해주세요.";
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = "너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.";
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> signInWithApple() async =>
      _signInWithProvider(() => appleUseCase.execute());

  Future<void> signInWithGoogle() async =>
      _signInWithProvider(() => googleUseCase.execute());

  Future<void> updateUser(AuthEntity entity) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await updateUserUseCase.execute(entity);
      state = state.copyWith(user: entity, status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
