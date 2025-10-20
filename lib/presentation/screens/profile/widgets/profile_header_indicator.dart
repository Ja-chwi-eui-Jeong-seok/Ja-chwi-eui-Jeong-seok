import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/mission_providers.dart';
import 'package:go_router/go_router.dart';

class ProfileHeaderIndicator extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  final VoidCallback? onEditProfile;

  const ProfileHeaderIndicator({super.key, this.extra, this.onEditProfile});

  @override
  ConsumerState<ProfileHeaderIndicator> createState() =>
      _ProfileHeaderIndicatorState();
}

class _ProfileHeaderIndicatorState extends ConsumerState<ProfileHeaderIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage =
        widget.extra?['imageFullUrl'] ?? 'assets/images/profile/black.png';
    final nickname = widget.extra?['nickname'] ?? '닉네임';

    final userProfileAsync = ref.watch(userProfileProvider);

    // 컬러 그라데이션 생성 함수
    List<Color> generateGradientColors() {
      const startColor = Color(0xFFF6CE1A);
      const endColor = Color(0xFFF39D13);
      const steps = 14;

      List<Color> colors = [];

      for (int i = 0; i < steps; i++) {
        final t = i / (steps - 1);
        final r = ((startColor.r * 255 + (endColor.r * 255 - startColor.r * 255) * t)).round() & 0xFF;
        final g = ((startColor.g * 255 + (endColor.g * 255 - startColor.g * 255) * t)).round() & 0xFF;
        final b = ((startColor.b * 255 + (endColor.b * 255 - startColor.b * 255) * t)).round() & 0xFF;
        colors.add(Color.fromARGB(0xFF, r, g, b));
      }

      return colors;
    }

    final List<Color> gradientColors = generateGradientColors();

    return userProfileAsync.when(
      data: (userProfile) {
        final missionCount = userProfile.missionCount;

        // 현재 레벨 (0~6 → 1렙, 7~13 → 2렙, ...)
        final currentLevel = (missionCount ~/ 7) + 1;

        // 현재 레벨에서 수행한 미션 수 (0~6)
        final missionsInCurrentLevel = missionCount % 7;

        // 진행률 0~1
        final percent = (missionsInCurrentLevel == 0 && missionCount != 0) ? 0.0 : missionsInCurrentLevel / 7;

        // 인디케이터 색상
        final indicatorColors = (missionCount == 0 || missionCount % 7 == 0)
            ? [Colors.transparent]  // 레벨 업 직후 투명
            : gradientColors;

        // 다음 레벨까지 필요한 미션 수
        final missionsForNextLevel = currentLevel * 7;

        // 애니메이션 초기화
        _animation = Tween<double>(begin: 0, end: percent).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
        _controller.forward(from: 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 레벨 / 진행 텍스트
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Column(
                children: [
                  Text('LV $currentLevel',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text('$missionCount/$missionsForNextLevel',
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 원형 인디케이터
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    return SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(
                        painter: MultiColorArcPainter(
                          colors: indicatorColors,
                          percent: _animation.value,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                // 중앙 프로필 이미지 + 닉네임
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(65),
                      child: SizedBox(
                        width: 105,
                        height: 105,
                        child: Image.asset(selectedImage, fit: BoxFit.fitHeight),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(nickname,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            context.go('/profile', extra: widget.extra);
                          },
                          child: const Icon(Icons.edit_square,
                              size: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
          width: 100, height: 100, child: CircularProgressIndicator()),
      error: (error, stack) =>
          SizedBox(width: 100, height: 100, child: Text('오류: $error')),
    );
  }
}

/// 부드러운 7단계 진행 구간 커스텀 페인터
class MultiColorArcPainter extends CustomPainter {
  final List<Color> colors;
  final double percent;
  final double strokeWidth;

  MultiColorArcPainter({required this.colors, required this.percent, this.strokeWidth = 24});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 배경 먼저
    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, basePaint);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    double startAngle = -pi / 2; // 12시 정각
    const int segmentsPerStep = 30;
    final totalSweep = 2 * pi;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      final stepSweep = totalSweep / colors.length;
      final segmentSweep = stepSweep / segmentsPerStep;

      for (int j = 0; j < segmentsPerStep; j++) {
        double currentProgress = (i + j / segmentsPerStep) / colors.length;
        if (currentProgress > percent) break;

        if (i == 0 && j == 0) {
          paint.strokeCap = StrokeCap.round;
        } else if (currentProgress + segmentSweep / 2 >= percent) {
          paint.strokeCap = StrokeCap.round;
        } else {
          paint.strokeCap = StrokeCap.butt;
        }

        canvas.drawArc(
          rect,
          startAngle - j * segmentSweep,
          -segmentSweep,
          false,
          paint,
        );
      }

      startAngle -= stepSweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
