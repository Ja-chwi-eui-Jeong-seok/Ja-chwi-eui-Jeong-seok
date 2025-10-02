class ReportEntity {
  final String id;
  final String userId;       // 신고한 사람
  final String targetId;     // 신고 대상
  final String reason;
  final DateTime createdAt;

  ReportEntity({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.reason,
    required this.createdAt,
  });
}
