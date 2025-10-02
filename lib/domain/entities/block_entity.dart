class BlockEntity {
  final String id; // 문서 ID
  final String userId; // 차단 당한 유저
  final String blockedBy; // 차단한 관리자/유저
  final String? reason; // 차단 사유
  final DateTime createdAt;

  BlockEntity({
    required this.id,
    required this.userId,
    required this.blockedBy,
    this.reason,
    required this.createdAt,
  });
}
