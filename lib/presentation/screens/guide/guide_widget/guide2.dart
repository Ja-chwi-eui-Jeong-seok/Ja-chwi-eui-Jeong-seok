import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Guide2 extends StatelessWidget {
  final VoidCallback onNext;
  final String uid;
  final String nickname;
  final String? imageFullUrl;
  final String? thumbUrl;
  final String? color;
  const Guide2({super.key, 
    required this.onNext, 
    required this.uid,
    required this.nickname,
    this.imageFullUrl,
    this.thumbUrl,
    this.color});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 화면 비율 기준으로 강조 영역 설정
    final highlightRect = Rect.fromLTWH(
      size.width * 0.02,
      size.height * 0.115,
      size.width * 0.96,
      size.height * 0.222,
    );

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          // 강조 영역 + 반투명 배경
          CustomPaint(
            size: size,
            painter: _OverlayPainter(highlightRect),
          ),

          // 설명 텍스트 + 화살표
          Positioned(
            top: highlightRect.bottom + size.height * 0.02, // 강조 영역 바로 아래
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.arrow_turn_down_right,
                    color: Colors.white,
                    size: size.width * 0.07, // 화면 비율로 크기 조절
                  ),
                  SizedBox(
                    width: size.width * 0.03,
                  ),
                  SizedBox(
                    width: size.width * 0.7,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '상단의 ',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextSpan(
                            text: '레벨',
                            style: TextStyle(
                              fontSize: 22, // 더 크게 강조
                            ),
                          ),
                          TextSpan(
                            text: '을 올리기 위해\n',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextSpan(
                            text: '미션',
                            style: TextStyle(
                              fontSize: 20, // 크기 다르게
                            ),
                          ),
                          TextSpan(
                            text: '을 클리어 해보세요!',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect highlightRect;
  _OverlayPainter(this.highlightRect);

  @override
  void paint(Canvas canvas, Size size) {
    // 새 레이어 생성
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 전체 반투명 배경
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // 강조 영역 빛나는 효과 (Glow)
    final glowPaint = Paint()
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.outer, 20) // 블러 크기 조절
      ..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect, const Radius.circular(24)),
      glowPaint,
    );

    // 강조 영역 완전 투명 처리
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect, const Radius.circular(24)),
      clearPaint,
    );

    // 레이어 복원
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) => false;
}
