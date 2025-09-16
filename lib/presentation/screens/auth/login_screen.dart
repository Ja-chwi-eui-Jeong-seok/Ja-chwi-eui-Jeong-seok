import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/login_button.dart';
import 'package:ja_chwi/presentation/screens/auth/login_widget/wave_text.dart';
import 'package:ja_chwi/presentation/screens/auth/privacy_policy_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showPrivacyPolicy(BuildContext context) async {
    final accepted = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    ); // 로그인 성공시 개인정보처리방침 동의 여부 확인 페이지로 이동

    if (accepted == true) {
      // 사용자가 개인정보처리방침에 동의하면 동의 완료 후 나타나지 않게 만들 예정
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 센터 이미지
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WaveText(text: '자취 준비중...'), // 텍스트애니메이션 넣을 예정

                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/change_image/black.png',
                      height: 150,
                    ), // 캐릭터이미지
                  ],
                ),
              ),
            ),
            const LoginButton(),
            SizedBox(height: 20), // 아래 여백
          ],
        ),
      ),
    );
  }
}
