import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/auth_provider.dart';
import 'package:ja_chwi/presentation/screens/auth/viewmodel/auth_view_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginButton extends ConsumerWidget {
  final Future<void> Function()? onLoginSuccess;

  const AppleLoginButton({super.key, this.onLoginSuccess});

  Future<void> _handleAppleLogin(BuildContext context, WidgetRef ref) async {
    try {
      if (kDebugMode) {
        print('🍎 Apple 로그인 시작');
        print('🍎 현재 상태: ${ref.read(authNotifierProvider).status}');
      }

      final authNotifier = ref.read(authNotifierProvider.notifier);
      if (kDebugMode) {
        print('🍎 AuthNotifier 가져옴');
      }

      await authNotifier.signInWithApple();
      if (kDebugMode) {
        print('🍎 signInWithApple() 완료');
      }

      if (!context.mounted) {
        if (kDebugMode) {
          print('🍎 Context가 mounted되지 않음');
        }
        return;
      }

      final latestState = ref.read(authNotifierProvider);

      if (kDebugMode) {
        print('🍎 Apple 로그인 상태: ${latestState.status}');
        print('🍎 사용자 정보: ${latestState.user?.uid}');
      }

      if (latestState.status == AuthStatus.success) {
        if (kDebugMode) {
          print('🍎 Apple 로그인 성공');
        }
        if (onLoginSuccess != null) {
          if (kDebugMode) {
            print('🍎 onLoginSuccess 콜백 실행');
          }
          await onLoginSuccess!();
        } else {
          if (kDebugMode) {
            print('🍎 onLoginSuccess 콜백이 null');
          }
        }
      } else if (latestState.status == AuthStatus.error) {
        if (kDebugMode) {
          print('🍎 Apple 로그인 에러: ${latestState.errorMessage}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple 로그인 실패: ${latestState.errorMessage}')),
        );
      } else {
        if (kDebugMode) {
          print('🍎 예상치 못한 상태: ${latestState.status}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('🍎 Apple 로그인 예외: $e');
        print('🍎 Stack trace: $stackTrace');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple 로그인 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    // iOS에서만 Apple 로그인 버튼 표시

    if (!Platform.isIOS) {
      return SizedBox.shrink(); // Android에서는 버튼 숨김
    }

    return Container(
      height: 56, // iPad에서 더 쉽게 터치할 수 있도록 높이 증가
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: isLoading
              ? null
              : () {
                  if (kDebugMode) {
                    print('🍎 Apple 로그인 버튼 클릭됨');
                  }
                  _handleAppleLogin(context, ref);
                },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SignInWithAppleButton(
              style: SignInWithAppleButtonStyle.black,
              onPressed: () {
                if (!isLoading) {
                  if (kDebugMode) {
                    print('🍎 Apple 로그인 버튼 클릭됨 (SignInWithAppleButton)');
                  }
                  _handleAppleLogin(context, ref);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
