import 'package:flutter/material.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // 언덕
        Positioned(
          bottom: -0.1 * screenHeight, // 화면 높이 비율
          left: -0.55 * screenWidth, // 화면 너비 비율
          right: -0.55 * screenWidth,
          child: Container(
            height: 0.45 * screenHeight, // 높이도 비율로
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(0.45 * screenHeight),
              ),
            ),
          ),
        ),
        // 그라디언트
        Positioned(
          bottom: -0.3 * screenHeight,
          left: -0.65 * screenWidth,
          right: -0.65 * screenWidth,
          child: Container(
            height: screenHeight * 1.0, // 화면 전체 높이
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(0.4 * screenHeight),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0),
                ],
                stops: const [0.3, 0.4], // 그라디언트 시작과 끝 비율
              ),
            ),
          ),
        ),
      ],
    );
  }
}
