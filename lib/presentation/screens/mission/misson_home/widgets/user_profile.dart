import 'package:ja_chwi/core/utils/level_calculator.dart';

class UserProfile {
  final String nickname;
  final String imageFullUrl;
  final int missionCount;
  final String level; // 계산된 레벨

  UserProfile({
    required this.nickname,
    required this.imageFullUrl,
    required this.missionCount,
    required this.level,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final missionCount = map['mission_count'] as int? ?? 0;

    return UserProfile(
      nickname: map['nickname'] as String? ?? '이름없음',
      imageFullUrl:
          map['imageFullUrl'] as String? ?? 'assets/images/profile/black.png',
      missionCount: missionCount,
      level: calculateLevel(missionCount), // "Lv.1", "Lv.2" 형태로 가공
    );
  }
}
