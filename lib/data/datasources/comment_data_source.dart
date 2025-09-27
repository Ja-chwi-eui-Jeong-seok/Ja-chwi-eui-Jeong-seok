import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/dto/comment_dto.dart';

enum CommentOrder { latest, popular }

abstract interface class CommentDataSource {
  Future<String> create(CommentDto dto);

  Future<String> createMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  });

  /// ✅ 생성 후, 서버에서 다시 읽어 Timestamp가 해석된 DTO를 반환
  Future<CommentDto> createAndGetMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  });

  Future<PagedResult<CommentDto>> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit,
    DocumentSnapshot? startAfterDoc,
  });

  Future<void> incLike(String id, int delta);
  Future<void> update(String id, Map<String, dynamic> patch);
  Future<void> softDelete(String id);
}
