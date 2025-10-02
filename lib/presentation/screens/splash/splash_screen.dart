import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:ja_chwi/presentation/providers/bottom_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // 애니메이션 완료 → 유저 상태 확인 후 이동
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Firestore에서 user_profile uid 기준으로 데이터 조회
          final extraData = await fetchUserData(user.uid);
          // Firestore에서 유저 데이터 확인
          final userProfileDoc = await FirebaseFirestore.instance
              .collection('user_profile')
              .doc(user.uid)
              .get(); // 계정이 있는지 확인

          final usersDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(); // 개인정보동의 있는지 확인

          final profilesDoc = await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .get(); // 캐릭터생성 확인

          if (userProfileDoc.exists && usersDoc.exists && profilesDoc.exists) {
            // 프로필 계정, 개인정보동의, 캐릭터 모두 있음
            GoRouter.of(context).go('/home', extra: extraData);
          } else if (!userProfileDoc.exists) {
            //  계정 없음
            GoRouter.of(context).go('/login');
          } else if (!usersDoc.exists) {
            // 개인정보 동의 없음
            GoRouter.of(context).go('/privacy-policy', extra: extraData);
          } else {
            // 개인정보 동의 없음
            GoRouter.of(context).go('/profile-flow', extra: extraData);
          }
        } else {
          // 로그인 안 되어 있으면 → 로그인 화면 이동
          GoRouter.of(context).go('/login');
        }
      }
    });
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '자취의 정석',
              style: TextStyle(
                fontSize: 52,
                fontFamily: 'GamjaFlower',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Builder(
                builder: (_) {
                  try {
                    return Lottie.asset(
                      'assets/config/json/intro_monji.json',
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller
                          ..duration = composition.duration
                          ..forward();
                      },
                    );
                  } catch (e) {
                    print('Lottie load error: $e');
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
