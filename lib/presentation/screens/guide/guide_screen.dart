import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        GoRouter.of(context).go('/home'); // 다 끝나면 가이드 종료
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// ✅ 이미 만들어둔 HomeScreen
        const HomeScreen(),

        /// ✅ 현재 단계의 가이드 (반투명 오버레이)
        steps[current](_nextStep),
      ],
    );
  }
}
