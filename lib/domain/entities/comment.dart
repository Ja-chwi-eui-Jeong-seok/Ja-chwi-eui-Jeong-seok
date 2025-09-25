class Comment {
  final String id;
  final String communityId;
  final String uid;
  final String nickName;
  final String noteDetail;
  final int likeCount;
  final bool moderated;
  final List<String> violations;
  final DateTime createAt;
  final DateTime? updateAt;
  final DateTime? deleteAt;
  final bool deleteYn;

  const Comment({
    required this.id,
    required this.communityId,
    required this.uid,
    required this.nickName,
    required this.noteDetail,
    required this.likeCount,
    required this.moderated,
    required this.violations,
    required this.createAt,
    this.updateAt,
    this.deleteAt,
    required this.deleteYn,
  });
}
