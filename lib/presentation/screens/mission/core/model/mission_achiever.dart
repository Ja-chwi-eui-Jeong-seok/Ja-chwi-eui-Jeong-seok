import 'package:intl/intl.dart';

class MissionAchiever {
  final String name;
  final String time;
  final String level;
  final String imageFullUrl;

  MissionAchiever({
    required this.name,
    required this.time,
    required this.level,
    required this.imageFullUrl,
  });

  factory MissionAchiever.fromMap(Map<String, dynamic> map) {
    final completedAt = map['completedAt'] as DateTime;

    // 미션 카운트를 기반으로 레벨 계산
    final missionCount = map['mission_count'] as int? ?? 0;
    int level = (missionCount / 7).floor() + 1;
    if (level > 10) level = 10; // 최대 레벨 10으로 제한

    return MissionAchiever(
      name: map['nickname'] as String? ?? '이름없음',
      time: '${DateFormat('HH:mm').format(completedAt)} 완료',
      level: 'Lv.$level',
      imageFullUrl:
          map['imageFullUrl'] as String? ??
          'assets/images/profile/black.png', // 기본 이미지
    );
  }
}
