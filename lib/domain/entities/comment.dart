// lib/domain/entities/comment.dart
//
// Domain Layer Entity (Firebase 모름)
// - DTO ↔ Entity 변환은 Repository에서 담당
// - DateTime 사용 (UI/도메인 친화적)
// - 삭제는 소프트 삭제 플래그(deleteYn)로 판단

class Comment {
  // 고유키 = Firestore doc.id
  final String id;

  // FK
  final String communityId;

  // 작성자 uid
  final String uid;

  // 댓글 내용
  final String noteDetail;

  // 집계 좋아요 수(실제 per-user 좋아요는 별도 컬렉션에서 관리)
  final int likeCount;

  // 생성/수정/삭제 시각
  final DateTime createAt; // comment_create_date
  final DateTime? updateAt; // comment_update_date
  final DateTime? deleteAt; // comment_delete_date

  // 소프트 삭제 여부
  final bool deleteYn; // comment_delete_yn

  // 금칙어 로그(필요 시)
  final List<String>? commentLog;

  const Comment({
    required this.id,
    required this.communityId,
    required this.uid,
    required this.noteDetail,
    required this.likeCount,
    required this.createAt,
    this.updateAt,
    this.deleteAt,
    required this.deleteYn,
    this.commentLog,
  });

  Comment copyWith({
    String? noteDetail,
    int? likeCount,
    DateTime? updateAt,
    DateTime? deleteAt,
    bool? deleteYn,
    List<String>? commentLog,
  }) {
    return Comment(
      id: id,
      communityId: communityId,
      uid: uid,
      noteDetail: noteDetail ?? this.noteDetail,
      likeCount: likeCount ?? this.likeCount,
      createAt: createAt,
      updateAt: updateAt ?? this.updateAt,
      deleteAt: deleteAt ?? this.deleteAt,
      deleteYn: deleteYn ?? this.deleteYn,
      commentLog: commentLog ?? this.commentLog,
    );
  }

  // 편의: 삭제 상태 여부
  bool get isDeleted => deleteYn;
}
