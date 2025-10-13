import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/google_login_button.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/wave_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // iPad 감지
    final isLandscape = screenSize.width > screenSize.height; // 가로모드 감지

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 100.0 : (isLandscape ? 40.0 : 20.0),
            vertical: isTablet ? 60.0 : (isLandscape ? 10.0 : 20.0),
          ),
          child: isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context, isTablet),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: isTablet ? 80 : 40),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WaveText(text: '자취의 정석\n시작하기'),
                SizedBox(height: isTablet ? 60 : 40),
                Image.asset(
                  'assets/images/profile/black.png',
                  width: isTablet ? 200 : 150,
                  height: isTablet ? 200 : 150,
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
        SizedBox(height: isTablet ? 40 : 20),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        // 왼쪽: 로고와 텍스트
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WaveText(text: '자취의 정석\n시작하기'),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/profile/black.png',
                  width: 120,
                  height: 120,
                ),
              ],
            ),
          ),
        ),
        // 오른쪽: 로그인 버튼
        Expanded(
          flex: 1,
          child: Center(
            child: GoogleLoginButton(
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
          ),
        ),
      ],
    );
  }
}
