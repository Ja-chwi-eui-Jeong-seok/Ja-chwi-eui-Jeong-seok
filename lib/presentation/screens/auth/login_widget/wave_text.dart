import 'package:flutter/material.dart';
import 'dart:math';

class WaveText extends StatefulWidget {
  final String text;
  const WaveText({super.key, required this.text});

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 속도 조절
    )..repeat(); // 계속 반복
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.text.length, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double offsetY =
                sin((_controller.value * 2 * pi) - (index * 0.5)) *
                10; // 가운데 + 오른쪽부터, - 왼쪽부터 웨이브
            return Transform.translate(
              offset: Offset(0, offsetY), // 글자당 위아래 움직임 조절
              child: Text(
                widget.text[index],
                style: const TextStyle(
                  fontFamily: 'GamjaFlower',
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
