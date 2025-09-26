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
  Future<String> createMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  }) async {
    final ref = await col.add({
      'community_id': communityId,
      'uid': uid,
      'note_detail': noteDetail,
      'like_count': 0,
      'comment_create_date': FieldValue.serverTimestamp(),
      'comment_delete_yn': false,
    });
    return ref.id;
  }

  @override
  Future<CommentDto> createAndGetMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  }) async {
    // 1) 문서 id를 먼저 확정
    final ref = col.doc();

    // 2) 서버 타임스탬프 포함해 기록
    await ref.set({
      'community_id': communityId,
      'uid': uid,
      'note_detail': noteDetail,
      'like_count': 0,
      'comment_create_date': FieldValue.serverTimestamp(),
      'comment_delete_yn': false,
    });

    // 3) 서버에서 "다시" 읽어 해석된 Timestamp를 확보
    final snap = await ref.get(const GetOptions(source: Source.server));
    final data = snap.data();
    if (data == null) {
      throw StateError('Failed to fetch created comment from server.');
    }
    return CommentDto.fromFirebase(ref.id, data);
  }

  @override
  Future<PagedResult<CommentDto>> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit = 20,
    DocumentSnapshot<Object?>? startAfterDoc,
  }) async {
    Query<Map<String, dynamic>> q = col
        .where('community_id', isEqualTo: communityId)
        .where('comment_delete_yn', isEqualTo: false);

    if (order == CommentOrder.latest) {
      q = q.orderBy('comment_create_date', descending: true);
    } else {
      q = q
          .orderBy('like_count', descending: true)
          .orderBy('comment_create_date', descending: true);
    }

    q = q.limit(limit);
    if (startAfterDoc != null) q = q.startAfterDocument(startAfterDoc);

    final snap = await q.get();
    final items = snap.docs
        .map((d) => CommentDto.fromFirebase(d.id, d.data()))
        .toList();
    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;

    return PagedResult(
      items: items,
      lastDoc: lastDoc,
      hasMore: snap.docs.length == limit,
    );
  }

  @override
  Future<void> incLike(String id, int delta) {
    return col.doc(id).update({'like_count': FieldValue.increment(delta)});
  }

  @override
  Future<void> update(String id, Map<String, dynamic> patch) {
    return col.doc(id).update({
      ...patch,
      'comment_update_date': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> softDelete(String id) {
    return col.doc(id).update({
      'comment_delete_yn': true,
      'comment_delete_date': FieldValue.serverTimestamp(),
    });
  }
}
