import 'package:cloud_firestore/cloud_firestore.dart';

/// comment_likes 컬렉션 전용 DTO
/// 설계 원칙:
/// - "좋아요 1건 = 문서 1개"
/// - 중복 방지를 위해 문서키(doc.id)를 `${commentId}_${uid}` 로 고정 생성
/// - 댓글 문서의 like_count 는 별도로 증가/감소(집계 캐시)
class CommentLikeDto {
  /// Firestore 문서 키
  final String id;

  /// 어떤 댓글에 대한 좋아요인지 (FK)
  final String commentId;

  /// 좋아요를 누른 사용자 uid
  final String uid;

  /// 생성 시각 (서버 시간)
  final Timestamp createdAt;

  CommentLikeDto({
    required this.id,
    required this.commentId,
    required this.uid,
    required this.createdAt,
  });

  /// `${commentId}_${uid}` 형태의 문서키를 생성 (중복 방지용)
  static String buildId({
    required String commentId,
    required String uid,
  }) => '${commentId}_$uid';

  /// Firestore → DTO
  factory CommentLikeDto.fromFirebase(String id, Map<String, dynamic> d) {
    return CommentLikeDto(
      id: id,
      commentId: d['comment_id'] as String,
      uid: d['uid'] as String,
      createdAt: d['created_at'] as Timestamp,
    );
  }

  /// 생성용 맵
  /// - created_at 은 서버 타임스탬프로 기록
  Map<String, dynamic> toCreateMap() => {
    'comment_id': commentId,
    'uid': uid,
    'created_at': FieldValue.serverTimestamp(),
  };
}
