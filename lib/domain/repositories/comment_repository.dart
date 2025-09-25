import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/domain/entities/comment.dart';

abstract interface class CommentRepository {
  Future<String> create(Comment input);
  Future<void> softDelete(String id);
  Future<void> update(String id, Map<String, dynamic> patch);
  Future<void> incLike(String id, int delta);
  Future<({List<Comment> items, DocumentSnapshot? lastDoc, bool hasMore})>
  fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit,
    DocumentSnapshot? startAfter,
  });
}
