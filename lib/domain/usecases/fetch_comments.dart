// lib/domain/usecases/fetch_comments.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/domain/repositories/comment_repository.dart';

class FetchComments {
  final CommentRepository repo;
  FetchComments(this.repo);

  /// 댓글 페이지네이션 조회
  /// - repo는 PagedComments를 반환하므로, VM에서 쓰기 편하도록 record로 변환해 반환
  Future<({List<Comment> items, DocumentSnapshot? lastDoc, bool hasMore})>
  call({
    required String communityId,
    required CommentOrder order,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final page = await repo.fetchByCommunity(
      communityId: communityId,
      order: order,
      limit: limit,
      startAfter: startAfter,
    );
    return (items: page.items, lastDoc: page.lastDoc, hasMore: page.hasMore);
  }
}
