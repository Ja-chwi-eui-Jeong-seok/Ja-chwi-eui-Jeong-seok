//도메인 인터페이스
abstract interface class CommentLikeRepository {
  /// 좋아요 토글
  /// true좋아요false해제
  Future<bool> toggle(String commentId, String uid);

  /// 댓글 중 좋아요한 댓글 id 집합
  Future<Set<String>> fetchLikedIds(String uid, List<String> commentIds);

  /// (선택) 단일 댓글의 현재 좋아요 수
  Future<int> getLikeCount(String commentId);
}
