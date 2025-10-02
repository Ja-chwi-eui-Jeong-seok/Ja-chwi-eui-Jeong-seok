import 'package:ja_chwi/domain/repositories/comment_like_repository.dart';
import 'package:ja_chwi/data/datasources/comment_like_data_source.dart';

class CommentLikeRepositoryImpl implements CommentLikeRepository {
  final CommentLikeDataSource ds;
  CommentLikeRepositoryImpl(this.ds);

  // 좋아요 토글
  @override
  Future<bool> toggle(String commentId, String uid) {
    return ds.toggle(commentId: commentId, uid: uid);
  }

  // 현재 화면의좋아요한 댓글 id 집합
  @override
  Future<Set<String>> fetchLikedIds(String uid, List<String> commentIds) {
    return ds.fetchLikedCommentIds(uid: uid, commentIds: commentIds);
  }

  @override
  Future<int> getLikeCount(String commentId) {
    return ds.getLikeCount(commentId: commentId);
  }
}
