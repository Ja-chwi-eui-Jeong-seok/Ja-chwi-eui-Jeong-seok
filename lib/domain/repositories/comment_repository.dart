import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/domain/entities/comment.dart';

class PagedComments {
  final List<Comment> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
  const PagedComments(this.items, this.lastDoc, this.hasMore);
}

abstract interface class CommentRepository {
  /// ✅ 생성 직후 서버값까지 반영된 Comment 반환
  Future<Comment> createAndGetMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  });

  Future<PagedComments> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit,
    DocumentSnapshot? startAfter,
  });

  Future<void> incLike(String id, int delta);
  Future<void> update(String id, Map<String, dynamic> patch);
  Future<void> softDelete(String id);

  /// 게시글별 댓글 수
  Future<int> getCountByCommunity(
    String communityId, {
    bool excludeDeleted = true,
  });
}
