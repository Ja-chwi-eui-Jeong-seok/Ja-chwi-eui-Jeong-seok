import 'package:intl/intl.dart';
import 'package:ja_chwi/core/utils/level_calculator.dart';

class MissionAchiever {
  final String userId;
  final String name;
  final String time;
  final String level;
  final String imageFullUrl;

  MissionAchiever({
    required this.userId,
    required this.name,
    required this.time,
    required this.level,
    required this.imageFullUrl,
  });

  factory MissionAchiever.fromMap(Map<String, dynamic> map) {
    final completedAt = map['completedAt'] as DateTime?;

    // 미션 카운트를 기반으로 레벨 계산
    final missionCount = map['mission_count'] as int? ?? 0;

    return MissionAchiever(
      userId: map['userId'] as String? ?? '',
      name: map['nickname'] as String? ?? '이름없음',
      time: completedAt != null
          ? '${DateFormat('HH:mm').format(completedAt)} 완료'
          : '',
      level: calculateLevel(missionCount),
      imageFullUrl:
          map['imageFullUrl'] as String? ??
          'assets/images/profile/black.png', // 기본 이미지
    );
  }
}
