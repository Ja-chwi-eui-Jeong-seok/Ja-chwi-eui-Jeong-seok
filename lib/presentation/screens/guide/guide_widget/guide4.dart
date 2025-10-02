import 'dart:math';
import 'package:flutter/material.dart';

class Guide4 extends StatelessWidget {
  final VoidCallback onNext;
  final String uid;
  final String nickname;
  final String? imageFullUrl;
  final String? thumbUrl;
  final String? color;
  final Offset circleCenter;
  final double circleRadius;

  const Guide4({
    super.key,
    required this.onNext,
    required this.uid,
    required this.nickname,
    this.imageFullUrl,
    this.thumbUrl,
    this.color,
    required this.circleCenter,
    required this.circleRadius,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ❌ 여기서 다시 Guide4CircleConfig로 덮어쓰지 않음!
    // final circleCenter = Guide4CircleConfig.getCenter(size); // 삭제
    // final circleRadius = Guide4CircleConfig.getRadius(size); // 삭제

    // 텍스트 위치
    final textLeft = size.width * 0.10;
    final textTop = size.height * 0.7;

    final guideTextSpan = TextSpan(
      children: const [
        TextSpan(
          text: '무엇을 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '했는지, 해야하는지\n',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '미션 탭',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '을 이용하여 확인해봐요!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: guideTextSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final arrowTarget = Offset(
      textLeft + textPainter.width / 2,
      textTop + textPainter.height + 16,
    );

    final control = Offset(
      (circleCenter.dx + arrowTarget.dx) / 2 - size.width * 0.15,
      (circleCenter.dy + arrowTarget.dy) / 2 - size.height * 0.05,
    );

    return GestureDetector(
      onTap: onNext,
      child: Stack(
        children: [
          CustomPaint(
            size: size,
            painter: _GlowCirclePainter(circleCenter, circleRadius),
          ),
          CustomPaint(
            size: size,
            painter: _CurvedArrowPainter(
              start: Offset(circleCenter.dx, circleCenter.dy - circleRadius),
              end: arrowTarget,
              control: control,
            ),
          ),
          Positioned(
            left: textLeft,
            top: textTop,
            child: RichText(text: guideTextSpan),
          ),
        ],
      ),
    );
  }
}

// (Glow + Arrow painter들은 기존 코드 그대로 사용)
class _GlowCirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  const _GlowCirclePainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(center, radius, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    const arrowLength = 16.0;
    const arrowAngle = pi / 4;
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
