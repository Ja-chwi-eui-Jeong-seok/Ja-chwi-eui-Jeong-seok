import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/login_button.dart';
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
                    WaveText(text: '자취의 정석 \n 시작하기'),
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
            LoginButton(
              onLoginSuccess: () async {
                // 1️⃣ 개인정보 처리방침 화면으로 이동
                final accepted = await context.push<bool>('/privacy-policy');

                if (accepted == true) {
                  // 2️⃣ 프로필 화면으로 이동
                  await context.push('/profile');

                  // 3️⃣ 프로필 완료 후 홈으로 이동
                  context.go('/home');
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
