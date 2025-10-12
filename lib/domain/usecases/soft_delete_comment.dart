// lib/domain/usecases/soft_delete_comment.dart
import 'package:ja_chwi/domain/repositories/comment_repository.dart';

class SoftDeleteComment {
  final CommentRepository repo;
  SoftDeleteComment(this.repo);

  Future<void> call(String commentId) {
    return repo.softDelete(commentId);
  }
}
