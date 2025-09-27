import 'package:flutter/material.dart';

class Guide1 extends StatelessWidget {
  final VoidCallback onNext;
  final String uid;
  final String nickname;
  final String? imageFullUrl;
  final String? thumbUrl;
  final String? color;
  const Guide1({super.key, 
    required this.onNext, 
    required this.uid,
    required this.nickname,
    this.imageFullUrl,
    this.thumbUrl,
    this.color});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          Container(color: Colors.black54),

          // 캐릭터
          Positioned(
            left: size.width * 0.07,
            bottom: size.height * 0.12,
            child: Image.asset(
              imageFullUrl ?? 'assets/images/profile/black.png',
              width: size.width * 0.3,
              height: size.width * 0.25,
            ),
          ),

          // 말풍선
          Positioned(
            left: size.width * 0.30,
            bottom: size.height * 0.25,
            child: CustomPaint(
              painter: BubblePainter(),
              child: Container(
                width: size.width * 0.55,
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.10,
                ),
                child: const Center(
                  child: Text(
                    '집 좀 치워라 \n확마 그냥',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 말풍선 + 꼬리 + 빛나는 효과
class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGlow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // 왼쪽 위 → 오른쪽 위 (둥근 모서리)
    path.moveTo(12, 0);
    path.lineTo(size.width - 12, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12);

    // 오른쪽 위 → 오른쪽 아래 (둥근 모서리)
    path.lineTo(size.width, size.height - 12);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 12,
      size.height,
    );

    // 오른쪽 아래 → 왼쪽 아래 (꼬리 포함)
    path.lineTo(28, size.height);

    // 꼬리 (왼쪽 벽과 일직선으로 떨어짐)
    path.lineTo(12, size.height); // 본체 왼쪽과 같은 세로선
    path.lineTo(12, size.height + 12); // 꼬리 아래쪽
    path.lineTo(24, size.height); // 다시 본체로 복귀

    // 왼쪽 아래 모서리 라운드 처리
    path.lineTo(12, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 12);

    // 왼쪽 아래 → 위로
    path.lineTo(0, 12);
    path.quadraticBezierTo(0, 0, 12, 0);

    path.close();

    // 그림자 + 채우기
    canvas.drawPath(path, paintGlow);
    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
