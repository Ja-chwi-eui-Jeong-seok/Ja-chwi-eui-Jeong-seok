import 'dart:math';
import 'package:flutter/material.dart';

class Guide3 extends StatelessWidget {
  final VoidCallback onNext;
  final String uid;
  final String nickname;
  final String? imageFullUrl;
  final String? thumbUrl;
  final String? color;
  const Guide3({super.key, 
    required this.onNext, 
    required this.uid,
    required this.nickname,
    this.imageFullUrl,
    this.thumbUrl,
    this.color});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 강조 원 위치/크기
    final circleCenter = Offset(size.width * 0.73, size.height * 0.464);
    final circleRadius = size.width * 0.07;

    // 텍스트 위치
    final textLeft = size.width * 0.12;
    final textTop = size.height * 0.32;

    // TextSpan으로 문장별 크기 지정
    final guideText = TextSpan(
      children: [
        TextSpan(
          text: '집먼지에게 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: '말을 걸어보세요!\n',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: 'AI기반',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: '으로 때론 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: '말동무,\n',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: '때로는 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: '조언자가 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        TextSpan(
          text: '되어줄 거에요!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
      ],
    );

    // TextPainter로 텍스트 크기 측정
    final textPainter = TextPainter(
      text: guideText,
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // 화살표 끝점 = 텍스트 하단 중앙
    const arrowMargin = 12.0;
    final arrowTarget = Offset(
      textLeft + textWidth + arrowMargin,
      textTop + textHeight / 1.5,
    );

    // 휘어짐 강도
    const curveStrength = 0.3;
    final control = Offset(
      (circleCenter.dx + arrowTarget.dx) / 1 - size.width * curveStrength * 2,
      (circleCenter.dy + arrowTarget.dy) / 2 -
          size.height * curveStrength * 0.05,
    );

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          // 강조 원 + 빛나는 효과 + 반투명 배경
          CustomPaint(
            size: size,
            painter: _GlowCircleOverlayPainter(circleCenter, circleRadius),
          ),

          // 곡선 화살표
          CustomPaint(
            size: size,
            painter: _CurvedArrowPainter(
              start: Offset(
                circleCenter.dx + circleRadius * 0.7,
                circleCenter.dy - circleRadius * 0.7,
              ),
              end: arrowTarget,
              control: control,
            ),
          ),

          // 설명 텍스트
          Positioned(
            left: textLeft,
            top: textTop,
            child: RichText(
              text: guideText,
            ),
          ),
        ],
      ),
    );
  }
}

/// 강조 원 + 빛나는 효과 + 반투명 배경
class _GlowCircleOverlayPainter extends CustomPainter {
  final Offset center;
  final double radius;
  const _GlowCircleOverlayPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 반투명 배경
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // 빛나는 강조 원
    final glowPaint = Paint()
      ..color = Colors.white
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius, glowPaint);

    // 중심 원 (투명)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(center, radius, clearPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 곡선 화살표
/// 곡선 화살표 (둥근 곡선)
class _CurvedArrowPainter extends CustomPainter {
  final Offset start;
  final Offset control;
  final Offset end;
  const _CurvedArrowPainter({
    required this.start,
    required this.control,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 중간점 기준으로 control 포인트 설정 (둥근 곡선)
    final midPoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    // control point를 중간점에서 위로 살짝 올려 곡선을 둥글게
    final control = Offset(
      midPoint.dx - size.width * -0.1, // x방향 휘어짐
      midPoint.dy - size.height * 0.04, // y방향 휘어짐
    );

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    // V자 화살표
    const arrowLength = 15.0;
    const arrowAngle = pi / 4;

    // 화살표 방향 계산
    final angle = atan2(end.dy - control.dy, end.dx - control.dx);

    final line1End = Offset(
      end.dx - arrowLength * cos(angle - arrowAngle),
      end.dy - arrowLength * sin(angle - arrowAngle),
    );
    final line2End = Offset(
      end.dx - arrowLength * cos(angle + arrowAngle),
      end.dy - arrowLength * sin(angle + arrowAngle),
    );

    canvas.drawLine(end, line1End, paint);
    canvas.drawLine(end, line2End, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
