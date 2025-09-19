import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //언덕
        Positioned(
          bottom: -550,
          left: -650,
          right: -650,
          child: Container(
            height: 850,
            decoration: BoxDecoration(
              color: Color(0xFFD9D9D9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(850)),
            ),
          ),
        ),
        //그라데이션
        Positioned(
          bottom: -500,
          left: -650,
          right: -650,
          child: Container(
            height: 1900,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(750)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0),
                ],
                stops: [0.3, 0.4], //그라데이션 시작 끝 위치조절
              ),
            ),
          ),
        ),
      ],
    );
  }
}
