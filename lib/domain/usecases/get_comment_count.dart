// lib/domain/usecases/get_comment_count.dart
import 'package:ja_chwi/domain/repositories/comment_repository.dart';

class GetCommentCount {
  final CommentRepository repo;
  GetCommentCount(this.repo);

  Future<int> call(String communityId, {bool excludeDeleted = true}) {
    return repo.getCountByCommunity(
      communityId,
      excludeDeleted: excludeDeleted,
    );
  }
}
