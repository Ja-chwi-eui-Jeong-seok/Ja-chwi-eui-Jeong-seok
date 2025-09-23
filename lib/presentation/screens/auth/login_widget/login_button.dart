import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback? onLoginSuccess;
  const LoginButton({super.key, this.onLoginSuccess});
  Future<void> _signInWithGoogle(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context); // async 전에 저장
    try {
      //구글 로그인
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 로그인 취소됨

      //구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      //Firebase Auth 크레덴셜 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //Firebase Auth 로그인
      await FirebaseAuth.instance.signInWithCredential(credential);

      //로그인 성공 → 개인정보처리방침으로 이동
      if (context.mounted) {
        context.go('/privacy-policy');
      }
    } catch (e) {
      print("구글 로그인 오류: $e");
      scaffold.showSnackBar(
        SnackBar(content: Text("로그인 실패: $e")),
      );
    }
  }

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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ), // 외부 테두리
                ),
              ),
              onPressed: () async {
                try {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  final googleUser = await googleSignIn.signIn();
                  if (googleUser != null && context.mounted) {
                    // 로그인 성공 시 프로필 설정 화면으로 이동
                    debugPrint('Google Sign-In Success: ${googleUser.email}');
                    context.go('/profile');
                  }
                } catch (error) {
                  // 로그인 실패 시 에러를 콘솔에 출력
                  debugPrint('Google Sign-In failed: $error');
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
                    try {
                      await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );
                      if (context.mounted) {
                        // 로그인 성공 시 프로필 설정 화면으로 이동
                        context.go('/profile');
                      }
                    } catch (e) {
                      // 사용자가 취소하는 등 에러 처리
                      debugPrint('Apple Sign-In failed: $e');
                    }
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
