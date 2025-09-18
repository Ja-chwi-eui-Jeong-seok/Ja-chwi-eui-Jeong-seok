import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MonjiJump extends StatelessWidget {
  final Color bodyColor = Color(0xFF6664CE); // 직접 16진수 지정
  //black: 1A1A1A red: FF9696 orange: FF9977 banana: FFEA97 sky: 7FA8DA night: 6664CE

  MonjiJump({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/json/monji_jump.json',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
      repeat: true, // 무한 반복
      animate: true, // 자동 재생
      delegates: LottieDelegates(
        values: [
          // body 색상
          ValueDelegate.color(const ['body', '**'], value: bodyColor),
          // bd1 색상
          ValueDelegate.color(const ['bd1', '**'], value: bodyColor),
          // bd2~bd6도 같은 방식으로 추가 가능
          ValueDelegate.color(const ['bd2', '**'], value: bodyColor),
          ValueDelegate.color(const ['bd3', '**'], value: bodyColor),
          ValueDelegate.color(const ['bd4', '**'], value: bodyColor),
          ValueDelegate.color(const ['bd5', '**'], value: bodyColor),
          ValueDelegate.color(const ['bd6', '**'], value: bodyColor),
        ],
      ),
    );
  }
}
