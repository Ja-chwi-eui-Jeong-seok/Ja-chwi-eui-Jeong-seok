import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/auth/auth_provider.dart';
import 'package:ja_chwi/presentation/screens/auth/auth_view_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleLoginButton extends ConsumerWidget {
  final Future<void> Function()? onLoginSuccess;

  const AppleLoginButton({super.key, this.onLoginSuccess});

  Future<void> _handleAppleLogin(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signInWithApple();

    if (!context.mounted) return;

    final latestState = ref.read(authNotifierProvider);
    if (latestState.status == AuthStatus.success) {
      if (onLoginSuccess != null) {
        await onLoginSuccess!();
      }
    } else if (latestState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(latestState.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SignInWithAppleButton(
          style: SignInWithAppleButtonStyle.white,
          onPressed: authState.status == AuthStatus.loading
              ? () {} // 비활성화 대신 빈 함수
              : () => _handleAppleLogin(context, ref),
        ),
      ),
    );
  }
}
