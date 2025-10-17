import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/dto/comment_dto.dart';

enum CommentOrder { latest, popular }

abstract interface class CommentDataSource {
  Future<CommentDto> createAndGetMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  });

  // 답글 생성 (서브컬렉션에 저장)
  Future<CommentDto> createReply({
    required String parentCommentId,
    required String communityId,
    required String uid,
    required String noteDetail,
  });

  // 답글 목록 조회
  Future<List<CommentDto>> fetchReplies(String parentCommentId);

  Future<PagedResult<CommentDto>> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit,
    DocumentSnapshot? startAfterDoc,
  });

  Future<void> incLike(String id, int delta);
  Future<void> update(String id, Map<String, dynamic> patch);
  Future<void> softDelete(String id);

  //게시글 댓글 카운트용
  Future<int> countByCommunity({
    required String communityId,
    bool excludeDeleted = true, // true면 삭제댓글 제외
  });
}
