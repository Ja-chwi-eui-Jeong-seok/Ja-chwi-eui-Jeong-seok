import 'package:flutter/material.dart';

class Guide1 extends StatelessWidget {
  final VoidCallback onNext;
  const Guide1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          Container(color: Colors.black54),

          // 캐릭터 (화면 비율 기준)
          Positioned(
            left: size.width * 0.07, // 화면 가로의 5% 지점
            bottom: size.height * 0.12, // 화면 세로의 60% 지점
            child: Image.asset(
              'assets/images/profile/black.png',
              width: size.width * 0.3, // 화면 너비의 20% 크기
              height: size.width * 0.25,
            ),
          ),

          // 말풍선 (캐릭터 머리 위쪽, 오른쪽 대각선)
          Positioned(
            left: size.width * 0.35, // 캐릭터 오른쪽
            bottom: size.height * 0.23, // 캐릭터보다 위쪽
            child: Container(
              width: size.width * 0.55,
              constraints: BoxConstraints(
                maxHeight: size.height * 0.13,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: const Text(
                  '집 좀 치워라 \n확마 그냥',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
