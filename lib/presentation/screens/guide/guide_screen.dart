import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 다시보지 않기용
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide1.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide2.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide3.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide4.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide5.dart';
import 'package:ja_chwi/presentation/screens/home/page/home_screen.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int current = 0;

  late final List<Widget Function(VoidCallback)> steps;

  @override
  void initState() {
    super.initState();
    steps = [
      (next) => Guide1(onNext: next),
      (next) => Guide2(onNext: next),
      (next) => Guide3(onNext: next),
      (next) => Guide4(
        onNext: next,
      ),
      (next) => Guide5(onNext: next),
    ];
  }

  void _nextStep() {
    setState(() {
      if (current < steps.length - 1) {
        current++;
      } else {
        GoRouter.of(context).go('/home');
      }
    });
  }

  Future<void> _closeGuide({bool dontShowAgain = false}) async {
    if (dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dontShowGuide', true);
    }
    GoRouter.of(context).go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeScreen(),

        // 현재 단계 가이드
        steps[current](_nextStep),

        // 우측 세로 점 인디케이터
        Positioned(
          bottom: 100,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(steps.length, (index) {
              final isActive = index == current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 6),
                width: isActive ? 16 : 12,
                height: isActive ? 16 : 12,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white54,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),

        // 마지막 가이드에서만 확인 버튼
        if (current == steps.length - 1)
          Positioned(
            bottom: 50, // 위치조절
            right: 20,
            child: Center(
              child: GestureDetector(
                onTap: () => _closeGuide(dontShowAgain: false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
