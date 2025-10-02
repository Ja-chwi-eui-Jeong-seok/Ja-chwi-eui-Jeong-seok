import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/circle_config.dart';

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

    // 강조 원 위치/크기
    final circleCenter = Guide4CircleConfig.getCenter(size);
    final circleRadius = Guide4CircleConfig.getRadius(size);

    // 텍스트 위치
    final textLeft = size.width * 0.10;
    final textTop = size.height * 0.7;

    // TextSpan
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

    // Text 크기 측정
    final textPainter = TextPainter(
      text: guideTextSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    // 화살표 끝점 = 텍스트 하단 중앙
    final arrowTarget = Offset(
      textLeft + textPainter.width / 2,
      textTop + textPainter.height + 16,
    );

    // 곡선 화살표 제어점 (자연스러운 C자 곡선)
    final control = Offset(
      (circleCenter.dx + arrowTarget.dx) / 2 - size.width * 0.15,
      (circleCenter.dy + arrowTarget.dy) / 2 - size.height * 0.05,
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

          // 설명 텍스트
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
        colors: [Colors.white.withOpacity(0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
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

/// 곡선 화살표
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

    // 화살촉
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
