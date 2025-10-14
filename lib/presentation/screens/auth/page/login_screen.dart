import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              // 로그인 안 되어 있으면 → 로그인 화면 이동
              if (!context.mounted) return;
              context.go('/login');
              return;
            }

            try {
              // Firestore에서 user_profile uid 기준으로 데이터 조회
              final extraData = await fetchUserData(user.uid);

              final userProfileDoc = await FirebaseFirestore.instance
                  .collection('user_profile')
                  .doc(user.uid)
                  .get(); // 계정이 있는지 확인

              final usersDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(); // 개인정보 동의 있는지 확인

              final profilesDoc = await FirebaseFirestore.instance
                  .collection('profiles')
                  .doc(user.uid)
                  .get(); // 캐릭터 생성 확인

              if (!context.mounted) return;

              if (userProfileDoc.exists &&
                  usersDoc.exists &&
                  profilesDoc.exists) {
                // 프로필 계정, 개인정보 동의, 캐릭터 모두 있음 → 홈으로
                context.go('/home', extra: extraData);
              } else if (!userProfileDoc.exists) {
                // 계정 없음 → 로그인 화면
                context.go('/login');
              } else if (!usersDoc.exists) {
                // 개인정보 동의 없음 → 개인정보처리방침
                context.go('/privacy-policy', extra: extraData);
              } else {
                // 캐릭터 생성 없음 → 프로필 생성 화면
                context.go('/profile-flow', extra: extraData);
              }
            } catch (e) {
              debugPrint('❌ 로그인 후 데이터 확인 오류: $e');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인 처리 중 오류가 발생했습니다.')),
              );
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
                print('login test file check2');
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

Future<Map<String, dynamic>> fetchUserData(String uid) async {
  final firestore = FirebaseFirestore.instance;

  // 1️⃣ user_profile 먼저 가져오기
  final userProfileDoc = await firestore
      .collection('user_profile')
      .doc(uid)
      .get();

  // user_profile 기준 uid 사용
  final userUid = userProfileDoc.id; // doc.id가 uid

  // 2️⃣ profiles에서 나머지 데이터 가져오기
  final profileDoc = await firestore.collection('profiles').doc(uid).get();

  final userData = {
    'uid': userUid, // ✅ user_profile 기준
    'nickname': profileDoc.data()?['nickname'] ?? '',
    'thumbUrl': profileDoc.data()?['thumbUrl'] ?? '',
    'mission_count': profileDoc.data()?['mission_count'] ?? '',
    'imageFullUrl': profileDoc.data()?['imageFullUrl'] ?? '',
    'color': profileDoc.data()?['color'] ?? '',
    'managerType': userProfileDoc.data()?['manager_type'] ?? '',
  };

  print('fetchUserData 결과: $userData');
  return userData;
}
