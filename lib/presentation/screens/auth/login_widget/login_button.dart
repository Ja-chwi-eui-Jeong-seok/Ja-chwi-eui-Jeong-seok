import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          /// 구글 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // 둥근모서리 4dp 권장
                  side: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ), // 외부 테두리
                ),
              ),
              onPressed: () async {
                // 파이어베이스 등 뭐시기 추가 예정
                GoogleSignIn googleSignIn = GoogleSignIn();
                await googleSignIn.signIn();
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

          /// 애플 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 48, // 최소 높이 48dp 권장
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1), // 외부 테두리
                borderRadius: BorderRadius.circular(24), // 버튼 모서리와 일치
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4), // Apple 권장 범위 4~8dp
                child: SignInWithAppleButton(
                  style: SignInWithAppleButtonStyle.white, // 흰색 버튼, Apple 권장
                  borderRadius: BorderRadius.circular(24), // 내부 버튼 모서리와 동일하게
                  onPressed: () async {
                    // Firebase Auth 등 연동
                    final credential =
                        await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                        );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
