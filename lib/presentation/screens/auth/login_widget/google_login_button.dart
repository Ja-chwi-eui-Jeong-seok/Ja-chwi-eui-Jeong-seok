import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/auth/viewmodel/auth_view_model.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/apple_login_button.dart';
import 'package:ja_chwi/presentation/providers/auth_provider.dart';

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
                      // 비동기 작업 후에는 context가 여전히 유효한지 확인하는 것이 좋습니다.
                      if (!context.mounted) return;

                      // signInWithGoogle() 호출 후 최신 상태를 다시 읽어옵니다.
                      final latestAuthState = ref.read(authNotifierProvider);
                      if (latestAuthState.status == AuthStatus.success) {
                        if (onLoginSuccess != null) await onLoginSuccess!();
                      } else if (latestAuthState.status == AuthStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(latestAuthState.errorMessage)),
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
