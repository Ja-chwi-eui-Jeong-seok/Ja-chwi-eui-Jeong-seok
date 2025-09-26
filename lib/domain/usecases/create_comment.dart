import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/domain/repositories/comment_repository.dart';

/// ✅ 생성 직후 서버시간까지 반영된 Comment 반환
class CreateComment {
  final CommentRepository repo;
  CreateComment(this.repo);

  Future<Comment> call({
    required String communityId,
    required String uid,
    required String noteDetail,
  }) {
    return repo.createAndGetMinimal(
      communityId: communityId,
      uid: uid,
      noteDetail: noteDetail,
    );
  }
}
