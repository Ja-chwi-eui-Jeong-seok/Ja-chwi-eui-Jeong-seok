import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment_like_data_source.dart';

class CommentLikeDataSourceImpl implements CommentLikeDataSource {
  final FirebaseFirestore fs;
  CommentLikeDataSourceImpl(this.fs);

  /// 좋아요(단건)
  CollectionReference<Map<String, dynamic>> get _likesCol =>
      fs.collection('comment_likes');

  /// like_count가 있는 문서
  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      fs.collection('community_comments');

  /// 좋아요 토글
  @override
  Future<bool> toggle({
    required String commentId,
    required String uid,
  }) async {
    final likeDocId = '${commentId}_$uid';
    final likeRef = _likesCol.doc(likeDocId);
    final commentRef = _commentsCol.doc(commentId);

    return fs.runTransaction<bool>((tx) async {
      final likeSnap = await tx.get(likeRef);

      if (likeSnap.exists) {
        // 해제: 좋아요 문서 삭제 + 카운트 감소
        tx.delete(likeRef);
        tx.update(commentRef, {'like_count': FieldValue.increment(-1)});
        return false;
      } else {
        // 생성: 좋아요 문서 생성 + 카운트 증가
        tx.set(likeRef, {
          'comment_id': commentId,
          'uid': uid,
          'created_at': FieldValue.serverTimestamp(),
        });
        tx.update(commentRef, {'like_count': FieldValue.increment(1)});
        return true; // 좋아요됨
      }
    });
  }

  /// 내가 좋아요한 댓글 id 집합 조회
  @override
  Future<Set<String>> fetchLikedCommentIds({
    required String uid,
    required List<String> commentIds,
  }) async {
    if (commentIds.isEmpty) return <String>{};

    const chunkSize = 10;
    final result = <String>{};

    for (var i = 0; i < commentIds.length; i += chunkSize) {
      final chunk = commentIds.sublist(
        i,
        i + chunkSize > commentIds.length ? commentIds.length : i + chunkSize,
      );

      final q = await _likesCol
          .where('uid', isEqualTo: uid)
          .where('comment_id', whereIn: chunk)
          .get();

      for (final doc in q.docs) {
        final data = doc.data();
        final cid = data['comment_id'] as String?;
        if (cid != null) result.add(cid);
      }
    }

    return result;
  }

  /// (선택) 단일 댓글의 현재 좋아요 수 읽기
  @override
  Future<int> getLikeCount({
    required String commentId,
    CollectionReference<Map<String, dynamic>>? commentsCol,
  }) async {
    // 1) 캐시 사용(권장)
    final col = commentsCol ?? _commentsCol;
    final snap = await col.doc(commentId).get();
    final data = snap.data();
    if (data != null && data.containsKey('like_count')) {
      final v = data['like_count'];
      if (v is int) return v;
      if (v is num) return v.toInt();
    }

    // 2) 캐시가 없다면 Aggregate Count로 정확히 계산
    final agg = await _likesCol
        .where('comment_id', isEqualTo: commentId)
        .count()
        .get();
    return agg.count ?? 0;
  }
}
