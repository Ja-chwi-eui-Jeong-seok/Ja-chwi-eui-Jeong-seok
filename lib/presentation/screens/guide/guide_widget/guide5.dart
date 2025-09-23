import 'dart:math';
import 'package:flutter/material.dart';

class Guide5 extends StatelessWidget {
  final VoidCallback onNext;
  const Guide5({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 강조 원 위치/크기
    final circleCenter = Offset(size.width * 0.613, size.height * 0.918);
    final circleRadius = size.width * 0.07;

    // 텍스트 위치
    final textLeft = size.width * 0.23;
    final textTop = size.height * 0.7;

    // TextSpan으로 제각각 크기
    final guideTextSpan = TextSpan(
      children: [
        TextSpan(
          text: '다른 ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '이웃들과\n',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '자취 ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '꿀팁',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '을 나누고 ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '소통',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '해봐요!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    // TextPainter로 화살표 위치 계산
    final textPainter = TextPainter(
      text: guideTextSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final arrowTarget = Offset(
      textLeft + textPainter.width / 2 + 30,
      textTop + textPainter.height + 12,
    );

    // 곡선 화살표 제어점
    const curveStrength = 0.3;
    final control = Offset(
      (circleCenter.dx + arrowTarget.dx) / 1 -
          size.width * curveStrength * 1.99,
      (circleCenter.dy + arrowTarget.dy) / 2 -
          size.height * curveStrength * 0.04,
    );

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          // 강조 원 + Glow
          CustomPaint(
            size: size,
            painter: _GlowCirclePainter(circleCenter, circleRadius),
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

          // 텍스트
          Positioned(
            left: textLeft,
            top: textTop,
            child: RichText(
              text: guideTextSpan,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 강조 원 + Glow 효과
class _GlowCirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  const _GlowCirclePainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 반투명 배경
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Glow 효과
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // 강조 원 (투명)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(center, radius, clearPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 기존 곡선 화살표
class _CurvedArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Offset control;

  const _CurvedArrowPainter({
    required this.start,
    required this.end,
    required this.control,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    final arrowLength = 16.0;
    final arrowAngle = pi / 4;
    final direction = (end - control).direction;

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
