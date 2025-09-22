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
      (next) => Guide4(onNext: next),
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
      await prefs.setBool("dontShowGuide", true);
    }
    GoRouter.of(context).go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// HomeScreen
        const HomeScreen(),

        /// 현재 단계의 가이드 (반투명 오버레이)
        steps[current](_nextStep),

        /// 하단 인디케이터 + 마지막 가이드 버튼
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // 점 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(steps.length, (index) {
                  final isActive = index == current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // 마지막 가이드에서만 표시
              if (current == steps.length - 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _closeGuide(dontShowAgain: false),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '닫기',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => _closeGuide(dontShowAgain: true),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '다시 보지 않기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
