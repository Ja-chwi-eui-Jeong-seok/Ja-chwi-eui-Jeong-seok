import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/google_login_button.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/wave_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WaveText(text: '자취의 정석\n시작하기'),
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/profile/black.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
            GoogleLoginButton(
              onLoginSuccess: () async {
                final accepted = await context.push<bool>('/privacy-policy');
                if (!context.mounted) return;

                if (accepted == true) {
                  await context.push('/profile');
                  if (!context.mounted) return;
                  context.go('/Guide');
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
