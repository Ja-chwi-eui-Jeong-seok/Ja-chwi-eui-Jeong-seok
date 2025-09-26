import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/auth_entity.dart';
import 'package:ja_chwi/domain/usecases/mock_auth_usecase.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final AuthEntity? user;
  final String errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthMockViewModel extends StateNotifier<AuthState> {
  final AppleLoginUseCase appleUseCase;
  // final GoogleLoginUseCase googleUseCase;

  AuthMockViewModel({
    required this.appleUseCase,
    // required this.googleUseCase,
  }) : super(AuthState());

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await appleUseCase.execute();
      if (user == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: "사용자 정보 없음",
        );
        return;
      }
      state = state.copyWith(user: user, status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Future<void> signInWithGoogle() async {
  //   state = state.copyWith(status: AuthStatus.loading);
  //   try {
  //     final user = await googleUseCase.execute();
  //     if (user == null) {
  //       state = state.copyWith(
  //         status: AuthStatus.error,
  //         errorMessage: "사용자 정보 없음",
  //       );
  //       return;
  //     }
  //     state = state.copyWith(user: user, status: AuthStatus.success);
  //   } catch (e) {
  //     state = state.copyWith(
  //       status: AuthStatus.error,
  //       errorMessage: e.toString(),
  //     );
  //   }
  // }
}
