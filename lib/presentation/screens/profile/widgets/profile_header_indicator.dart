import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ja_chwi/core/utils/level_calculator.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:go_router/go_router.dart';

class ProfileHeaderIndicator extends ConsumerWidget {
  final Map<String, dynamic>? extra;
  final VoidCallback? onEditProfile;

  const ProfileHeaderIndicator({super.key, this.extra, this.onEditProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = extra?['imageFullUrl'] ?? 'assets/images/profile/black.png';
    final userColor = extra != null && extra!['color'] != null
        ? Color(int.tryParse('0xFF${extra!['color']}') ?? 0xFF6664CE)
        : const Color(0xFF6664CE);
    final nickname = extra?['nickname'] ?? '닉네임';

    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        final missionCount = userProfile.missionCount;
        final currentLevel =
            int.tryParse(calculateLevel(missionCount).replaceAll('Lv.', '')) ?? 1;
        final missionsForNextLevel = currentLevel * 7;
        final missionsInCurrentLevel =
            (missionCount - ((currentLevel - 1) * 7)).clamp(0, 7);
        final percent = (missionsInCurrentLevel / 7).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1️⃣ 인디케이터 위 레벨 + 진행 텍스트
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.8),
              ),
              child: Column(
                children: [
                  Text(
                    'Lv.$currentLevel',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$missionsInCurrentLevel/$missionsForNextLevel',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // 2️⃣ 원형 진행률 + 중앙 이미지 + 닉네임/편집 아이콘
            Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi), // 좌우 반전
                  child: CircularPercentIndicator(
                    radius: 130,
                    lineWidth: 20.0,
                    percent: 1-(1 - percent),
                    animation: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.grey[300]!,
                    progressColor: userColor,
                    startAngle: 0.0, // 0도부터 시작
                  ),
                ),
                // 중앙 이미지 + 닉네임/편집 아이콘
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(65),
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: Image.asset(
                          selectedImage,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          //onTap: onEditProfile,
                           onTap: () {
                              context.go('/profile', extra: extra);
                            },
                            child: const Icon(
                            Icons.edit_square,
                            size: 20,
                            color: Colors.grey,
                          ),
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
        width: 120,
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        width: 120,
        height: 120,
        child: Center(child: Text('레벨 정보를 불러올 수 없습니다.\n$error')),
      ),
    );
  }
}
