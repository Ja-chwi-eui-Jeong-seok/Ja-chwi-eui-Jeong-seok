import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/level_calculator.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeProgress extends ConsumerWidget {
  const HomeProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        final missionCount = userProfile.missionCount;
        final levelString = calculateLevel(missionCount); // 'Lv.X'
        // 현재 레벨 (숫자만 추출)
        final currentLevel =
            int.tryParse(levelString.replaceAll('Lv.', '')) ?? 1;

        // 다음 레벨까지 필요한 총 미션 수
        final missionsForNextLevel = currentLevel * 7;

        // 현재 레벨에서 채운 미션 수
        final missionsInCurrentLevel = missionCount - ((currentLevel - 1) * 7);

        // 진행률 계산
        final percent = (missionsInCurrentLevel / 7).clamp(0.0, 1.0).toDouble();

        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 레벨 알약
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        levelString, // 'Lv.X'
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // 경험치
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$missionCount/$missionsForNextLevel', // '현재 미션 수 / 다음 레벨까지 필요한 미션 수'
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 진행 바
              Stack(
                children: [
                  LinearPercentIndicator(
                    lineHeight: 10.0,
                    percent: percent, // 계산된 진행률
                    barRadius: const Radius.circular(10),
                    linearGradient: const LinearGradient(
                      colors: [
                        Color(0xFF7FA8DA),
                        Color(0xFF6664CE),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    backgroundColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: 60,
        child: Center(child: Text('레벨 정보를 불러올 수 없습니다.\n$error')),
      ),
    );
  }
}
