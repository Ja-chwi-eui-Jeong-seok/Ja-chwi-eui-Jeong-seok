import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide1.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide2.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide3.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide4.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide5.dart';

class GuideOverlay extends StatefulWidget {
  const GuideOverlay({super.key});

  @override
  State<GuideOverlay> createState() => _GuideOverlayState();
}

class _GuideOverlayState extends State<GuideOverlay> {
  int current = 0;

  late final List<Widget Function(VoidCallback)> s;

  @override
  void initState() {
    super.initState();
    s = [
      (next) => Guide1(),
      (next) => Guide2(),
      (next) => Guide3(),
      (next) => Guide4(),
      (next) => Guide5(),
    ];
  }

  void _next() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return s[current](_next);
  }
}
