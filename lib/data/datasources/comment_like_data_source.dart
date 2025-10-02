import 'package:cloud_firestore/cloud_firestore.dart';

/// 댓글 좋아요(Data Source 인터페이스)

abstract interface class CommentLikeDataSource {
  /// - 이미 눌렀으면 해제(delete)하고 false 반환
  /// - 안 눌렀으면 생성(set)하고 true 반환
  /// - 내부에서 Firestore 트랜잭션으로 처리(원자성 보장)
  Future<bool> toggle({
    required String commentId,
    required String uid,
  });

  /// 사용자가 '보이는 댓글들' 중 어떤 것에 좋아요를 눌렀는지 확인
  /// - 반환: 좋아요된 commentId 집합
  Future<Set<String>> fetchLikedCommentIds({
    required String uid,
    required List<String> commentIds,
  });

  /// (선택) 단일 댓글의 현재 좋아요 수를 읽고 싶을 때 사용할 수 있는 헬퍼
  Future<int> getLikeCount({
    required String commentId,
    CollectionReference<Map<String, dynamic>>? commentsCol, // 주입 가능
  });
}
