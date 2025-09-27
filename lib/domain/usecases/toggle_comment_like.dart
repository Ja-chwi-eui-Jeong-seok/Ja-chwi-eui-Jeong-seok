import 'package:ja_chwi/domain/repositories/comment_like_repository.dart';

class ToggleCommentLike {
  final CommentLikeRepository repo;
  ToggleCommentLike(this.repo);

  Future<bool> call({
    required String commentId,
    required String uid,
  }) {
    return repo.toggle(commentId, uid);
  }
}
