// lib/data/datasources/comment_data_source_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/data/dto/comment_dto.dart';

class CommentDataSourceImpl implements CommentDataSource {
  final FirebaseFirestore fs;
  CommentDataSourceImpl(this.fs);

  CollectionReference<Map<String, dynamic>> get col =>
      fs.collection('community_comments');

  @override
  Future<String> create(CommentDto dto) async {
    final ref = await col.add(dto.toCreateMap());
    return ref.id;
  }

  @override
  Future<void> softDelete(String id) => col.doc(id).update({
    'community_delete_yn': true,
    'community_delete_date': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> update(String id, Map<String, dynamic> patch) =>
      col.doc(id).update(patch);

  @override
  Future<void> incLike(String id, int delta) async {
    await fs.runTransaction((tx) async {
      final ref = col.doc(id);
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final curr = (snap.data()!['like_count'] ?? 0) as int;
      tx.update(ref, {'like_count': curr + delta});
    });
  }

  @override
  Future<PagedResult<CommentDto>> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) async {
    Query<Map<String, dynamic>> q = col
        .where('community_id', isEqualTo: communityId)
        .where('community_delete_yn', isEqualTo: false);

    if (order == CommentOrder.latest) {
      q = q.orderBy('community_create_date', descending: true);
    } else {
      // 인기순: like_count desc, tie-breaker by create_date desc
      q = q
          .orderBy('like_count', descending: true)
          .orderBy('community_create_date', descending: true);
    }

    q = q.limit(limit);
    if (startAfterDoc != null) q = q.startAfterDocument(startAfterDoc);

    final snap = await q.get();
    final items = snap.docs
        .map((d) => CommentDto.fromFirebase(d.id, d.data()))
        .toList();
    final last = snap.docs.isNotEmpty ? snap.docs.last : null;

    return PagedResult(
      items: items,
      lastDoc: last,
      hasMore: snap.docs.length == limit,
    );
  }
}
