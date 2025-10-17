import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/data/dto/comment_dto.dart';

class CommentDataSourceImpl implements CommentDataSource {
  final FirebaseFirestore fs;
  CommentDataSourceImpl(this.fs);

  CollectionReference<Map<String, dynamic>> get col =>
      fs.collection('community_comments');

  // 답글 서브컬렉션 참조
  CollectionReference<Map<String, dynamic>> getReplyCol(
    String parentCommentId,
  ) => col.doc(parentCommentId).collection('replies');

  @override
  //댓글 생성
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

  // 답글 생성 (서브컬렉션에 저장)
  Future<CommentDto> createReply({
    required String parentCommentId,
    required String communityId,
    required String uid,
    required String noteDetail,
  }) async {
    // 1) 답글 문서 id를 먼저 확정
    final replyRef = getReplyCol(parentCommentId).doc();

    // 2) 서버 타임스탬프 포함해 기록
    final data = {
      'community_id': communityId,
      'uid': uid,
      'note_detail': noteDetail,
      'like_count': 0,
      'comment_create_date': FieldValue.serverTimestamp(),
      'comment_delete_yn': false,
      'parent_comment_id': parentCommentId,
      'depth': 1, // 답글은 깊이 1
    };

    await replyRef.set(data);

    // 3) 서버에서 "다시" 읽어 해석된 Timestamp를 확보
    final snap = await replyRef.get(const GetOptions(source: Source.server));
    final snapData = snap.data();
    if (snapData == null) {
      throw StateError('Failed to fetch created reply from server.');
    }
    return CommentDto.fromFirebase(replyRef.id, snapData);
  }

  // 답글 목록 조회
  Future<List<CommentDto>> fetchReplies(String parentCommentId) async {
    final snapshot = await getReplyCol(parentCommentId)
        .where('comment_delete_yn', isEqualTo: false)
        .orderBy('comment_create_date', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CommentDto.fromFirebase(doc.id, doc.data()))
        .toList();
  }

  @override //게시글 댓글 불러오기
  Future<PagedResult<CommentDto>> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit = 20,
    DocumentSnapshot<Object?>? startAfterDoc,
  }) async {
    //게시글 id와 같고 삭제되지 않은 댓글
    Query<Map<String, dynamic>> q = col
        .where('community_id', isEqualTo: communityId)
        .where('comment_delete_yn', isEqualTo: false);

    //최신순일때 정렬
    if (order == CommentOrder.latest) {
      q = q.orderBy('comment_create_date', descending: true);
    } else {
      //최신순 아닐때(추천순) 정렬
      q = q
          .orderBy('like_count', descending: true)
          .orderBy('comment_create_date', descending: true);
    }
    //제한갯수
    q = q.limit(limit);
    if (startAfterDoc != null) q = q.startAfterDocument(startAfterDoc);

    final snap = await q.get();
    final items = <CommentDto>[];

    // 각 댓글에 대해 답글도 함께 불러오기
    for (final doc in snap.docs) {
      final commentDto = CommentDto.fromFirebase(doc.id, doc.data());

      // 답글 목록 불러오기
      final replies = await fetchReplies(doc.id);

      // 답글이 있는 경우 replies 필드 설정
      final commentWithReplies = commentDto.copyWith(replies: replies);

      items.add(commentWithReplies);
    }

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

  @override
  Future<int> countByCommunity({
    required String communityId,
    bool excludeDeleted = true,
  }) async {
    Query<Map<String, dynamic>> q = col.where(
      'community_id',
      isEqualTo: communityId,
    );
    if (excludeDeleted) {
      q = q.where('comment_delete_yn', isEqualTo: false);
    }
    final snap = await q.count().get();
    return snap.count ?? 0;
  }
}
