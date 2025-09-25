import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/auth/auth_view_model.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/apple_login_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ja_chwi/presentation/screens/auth/auth_provider.dart';

class GoogleLoginButton extends ConsumerWidget {
  final Future<void> Function()? onLoginSuccess;

  const GoogleLoginButton({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          /// Google 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () async {
                      await authNotifier.signInWithGoogle();
                      if (!context.mounted) return;
                      if (authNotifier.state.status == AuthStatus.success) {
                        if (onLoginSuccess != null) await onLoginSuccess!();
                      } else if (authNotifier.state.status ==
                          AuthStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authNotifier.state.errorMessage),
                          ),
                        );
                      }
                    },
              icon: Image.asset('assets/images/google.png', height: 18),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          AppleLoginButton(),
        ],
      ),
    );
  }
}
