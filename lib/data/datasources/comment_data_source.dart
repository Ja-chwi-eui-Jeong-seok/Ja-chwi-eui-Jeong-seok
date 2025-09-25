// lib/data/datasources/comment_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/dto/comment_dto.dart';

enum CommentOrder { latest, popular }

abstract interface class CommentDataSource {
  Future<String> create(CommentDto dto);
  Future<void> softDelete(String id);
  Future<void> update(String id, Map<String, dynamic> patch);
  Future<void> incLike(String id, int delta); // +1 / -1
  Future<PagedResult<CommentDto>> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit,
    DocumentSnapshot? startAfterDoc,
  });
}
