import 'package:ja_chwi/domain/repositories/comment_like_repository.dart';

//현재 화면에 보이는 댓글들 중 좋아요한 댓글 id
class FetchUserLikedCommentIds {
  final CommentLikeRepository repo;
  FetchUserLikedCommentIds(this.repo);

  Future<Set<String>> call({
    required String uid,
    required List<String> commentIds,
  }) {
    return repo.fetchLikedIds(uid, commentIds);
  }
}
