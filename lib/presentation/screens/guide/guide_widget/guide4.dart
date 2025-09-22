import 'dart:math';
import 'package:flutter/material.dart';

class Guide4 extends StatelessWidget {
  final VoidCallback onNext;
  const Guide4({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 강조 원 위치/크기
    final circleCenter = Offset(size.width * 0.385, size.height * 0.918);
    final circleRadius = size.width * 0.07;

    // 설명 텍스트 문자열
    const guideText = "무엇을 했는지, 해야하는지 \n미션 탭을 이용하여 확인해봐요!";
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    // 텍스트 크기 측정
    final textPainter = TextPainter(
      text: const TextSpan(text: guideText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // 텍스트 배치 위치 (왼쪽 상단 기준)
    final textLeft = size.width * 0.12;
    final textTop = size.height * 0.7;

    // 화살표 끝점 = 텍스트 하단 중앙
    const arrowMargin = 12.0;
    final arrowTarget = Offset(
      textLeft + textWidth / 2,
      textTop + textHeight + arrowMargin,
    );

    // 휘어짐 강도
    const curveStrength = 0.3;
    final control = Offset(
      (circleCenter.dx + arrowTarget.dx) / 1 - size.width * curveStrength * 1.2,
      (circleCenter.dy + arrowTarget.dy) / 2 -
          size.height * curveStrength * 0.04,
    );

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          // 강조 원 + 반투명 배경
          CustomPaint(
            size: size,
            painter: _CircleOverlayPainter(circleCenter, circleRadius),
          ),

          // 곡선 화살표
          CustomPaint(
            size: size,
            painter: _CurvedArrowPainter(
              start: Offset(circleCenter.dx, circleCenter.dy - circleRadius),
              end: arrowTarget,
              control: control,
            ),
          ),

          // 설명 텍스트
          Positioned(
            left: textLeft,
            top: textTop,
            child: const Text(
              guideText,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 강조 원 + 반투명 배경
class _CircleOverlayPainter extends CustomPainter {
  final Offset center;
  final double radius;
  _CircleOverlayPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 반투명 배경
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // 강조 원 (투명)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(center, radius, clearPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 곡선 화살표
class _CurvedArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Offset control;

  _CurvedArrowPainter({
    required this.start,
    required this.end,
    required this.control,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 곡선 그리기
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    // 기존 삼각형 화살표 대신 > 모양으로 위로 세운 화살표
    final arrowLength = 16.0; // 화살표 길이
    final arrowAngle = pi / 4; // 45도 각도로 벌어지게
    final direction = (end - control).direction;

    // V자 모양 그리기
    final line1End = Offset(
      end.dx - arrowLength * cos(direction - arrowAngle),
      end.dy - arrowLength * sin(direction - arrowAngle),
    );
    final line2End = Offset(
      end.dx - arrowLength * cos(direction + arrowAngle),
      end.dy - arrowLength * sin(direction + arrowAngle),
    );

    canvas.drawLine(end, line1End, paint);
    canvas.drawLine(end, line2End, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
