class UserProfile {
  final String nickname;
  final String level;
  final String imageUrl;

  UserProfile({
    required this.nickname,
    required this.level,
    required this.imageUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final missionCount = map['mission_count'] as int? ?? 0;
    int level = (missionCount / 7).floor() + 1;
    if (level > 10) level = 10;

    return UserProfile(
      nickname: map['nickname'] as String? ?? '이름없음',
      level: 'LV $level',
      imageUrl:
          map['imageFullUrl'] as String? ?? 'assets/images/profile/black.png',
    );
  }
}
