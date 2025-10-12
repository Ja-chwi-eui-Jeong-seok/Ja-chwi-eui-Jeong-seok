import 'package:ja_chwi/core/utils/level_calculator.dart';

class MissionAchiever {
  final String userId;
  final String name;
  final String level;
  final String imageFullUrl;
  final int missionCount; // 전체 미션 횟수
  final int weekCount; // 주간 미션 횟수

  MissionAchiever({
    required this.userId,
    required this.name,
    required this.level,
    required this.imageFullUrl,
    required this.missionCount,
    required this.weekCount,
  });

  factory MissionAchiever.fromMap(Map<String, dynamic> map) {
    // 전체 미션 카운트를 기반으로 레벨 계산
    final missionCount = map['missionCount'] as int? ?? 0;

    return MissionAchiever(
      userId: map['userId'] as String? ?? '',
      name: map['nickname'] as String? ?? '이름없음',
      level: calculateLevel(missionCount),
      imageFullUrl:
          map['imageFullUrl'] as String? ??
          'assets/images/profile/black.png', // 기본 이미지
      missionCount: missionCount, // 전체 미션 카운트
      weekCount: map['weekCount'] as int? ?? 0, // 주간 미션 카운트
    );
  }
}
