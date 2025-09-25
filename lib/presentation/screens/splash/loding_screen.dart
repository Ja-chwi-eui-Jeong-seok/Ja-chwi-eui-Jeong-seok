import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class LodingScreen extends StatefulWidget {
  const LodingScreen({super.key});

  @override
  State<LodingScreen> createState() => _SplashPageState();
}

class _SplashPageState extends State<LodingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // 애니메이션이 끝났을 때 화면 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        GoRouter.of(context).go('/login'); // 초기 프로필 설정 창으로 가고 이미 만들어져 있으면 홈으로
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
