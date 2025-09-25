class Profile {
  final String nickname;
  final String imageFullUrl;
  final String dongName;
  final DateTime? createDate;
  final DateTime? updateDate;

  Profile({
    required this.nickname,
    required this.imageFullUrl,
    required this.dongName,
    this.createDate,
    this.updateDate,
  });

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'imageFullUrl': imageFullUrl,
        'dongName': dongName,
        'create_date': createDate?.toIso8601String(), // null이면 자동으로 null 저장
        'update_date': updateDate?.toIso8601String(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nickname: json['nickname'] as String? ?? '',
      imageFullUrl: json['imageFullUrl'] as String? ?? '',
      dongName: json['dongName'] as String? ?? '',
      createDate: json['create_date'] != null
          ? DateTime.tryParse(json['create_date'] as String)
          : null,
      updateDate: json['update_date'] != null
          ? DateTime.tryParse(json['update_date'] as String)
          : null,
    );
  }
}
