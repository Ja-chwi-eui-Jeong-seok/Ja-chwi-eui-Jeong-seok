import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        await _checkUserAndNavigate();
      }
    });
  }

  Future<void> _checkUserAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;

    // 🔹 1. 로그인 여부 확인
    if (user == null) {
      GoRouter.of(context).go('/login');
      return;
    }

    final firestore = FirebaseFirestore.instance;

    try {
      // 🔹 2. user_profile 문서 확인
      final userProfileDoc = await firestore
          .collection('user_profile')
          .doc(user.uid)
          .get();

      if (!userProfileDoc.exists) {
        GoRouter.of(context).go('/login');
        return;
      }

      // 🔹 3. users 문서 확인
      final usersDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      final usersData = usersDoc.data();
      print('🔥 usersDoc data: $usersData'); // 디버깅용 로그

      // privacy_consent 값 안전하게 읽기
      final privacyConsent = (usersData?['privacy_consent'] ?? false) == true;
      print('🔥 privacyConsent: $privacyConsent');

      if (!privacyConsent) {
        GoRouter.of(context).go('/privacy-policy');
        return;
      }

      // 🔹 4. profiles 문서 확인
      final profilesDoc = await firestore
          .collection('profiles')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      final profilesData = profilesDoc.data();
      print('🔥 profilesDoc data: $profilesData');

      final nickname = profilesData?['nickname'] ?? '';

      if (nickname.isEmpty) {
        GoRouter.of(context).go('/profile-flow');
        return;
      }

      // 🔹 5. 모든 조건 통과 시 홈으로 이동
      final extraData = {
        'uid': user.uid,
        'nickname': nickname,
        'thumbUrl': profilesData?['thumbUrl'] ?? '',
        'mission_count': profilesData?['mission_count'] ?? 0,
        'imageFullUrl': profilesData?['imageFullUrl'] ?? '',
        'color': profilesData?['color'] ?? '',
        'managerType': userProfileDoc.data()?['manager_type'] ?? false,
        'privacyConsent': privacyConsent,
      };

      GoRouter.of(context).go('/home', extra: extraData);
    } catch (e) {
      print('🔥 Splash navigation error: $e');
      GoRouter.of(context).go('/login'); // 예외 발생 시 로그인으로
    }
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
