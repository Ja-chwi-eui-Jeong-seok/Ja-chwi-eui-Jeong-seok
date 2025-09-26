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

    // 애니메이션 완료 → 유저 상태 확인 후 이동
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Firestore에서 유저 데이터 확인
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (doc.exists) {
            // 이미 등록된 유저 → 홈 이동
            GoRouter.of(context).go('/home');
          } else {
            // 신규 유저 → 로그인/가입 화면 이동
            GoRouter.of(context).go('/login');
          }
        } else {
          // 로그인 안 되어 있으면 → 로그인 화면 이동
          GoRouter.of(context).go('/login');
        }
      }
    });
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
