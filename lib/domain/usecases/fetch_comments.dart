// lib/domain/usecases/fetch_comments.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/domain/repositories/comment_repository.dart';

class FetchComments {
  final CommentRepository repo;
  FetchComments(this.repo);

  Future<({List<Comment> items, DocumentSnapshot? lastDoc, bool hasMore})>
  call({
    required String communityId,
    required CommentOrder order,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) => repo.fetchByCommunity(
    communityId: communityId,
    order: order,
    limit: limit,
    startAfter: startAfter,
  );
}
