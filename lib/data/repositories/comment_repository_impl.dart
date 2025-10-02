import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/data/dto/comment_dto.dart';
import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentDataSource ds;
  CommentRepositoryImpl(this.ds);

  Comment _toEntity(CommentDto d) => Comment(
    id: d.id,
    communityId: d.communityId,
    uid: d.uid,
    noteDetail: d.noteDetail,
    likeCount: d.likeCount,
    createAt: d.createAt.toDate().toUtc(),
    updateAt: d.updateAt?.toDate(),
    deleteAt: d.deleteAt?.toDate(),
    deleteYn: d.deleteYn,
    commentLog: d.commentLog,
  );

  @override
  Future<Comment> createAndGetMinimal({
    required String communityId,
    required String uid,
    required String noteDetail,
  }) async {
    final dto = await ds.createAndGetMinimal(
      communityId: communityId,
      uid: uid,
      noteDetail: noteDetail,
    );
    return _toEntity(dto); //서버시간 반영된 Entity
  }

  @override
  Future<PagedComments> fetchByCommunity({
    required String communityId,
    required CommentOrder order,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final page = await ds.fetchByCommunity(
      communityId: communityId,
      order: order,
      limit: limit,
      startAfterDoc: startAfter,
    );
    final items = page.items.map(_toEntity).toList();
    return PagedComments(items, page.lastDoc, page.hasMore);
  }

  @override
  Future<void> incLike(String id, int delta) => ds.incLike(id, delta);

  @override
  Future<void> update(String id, Map<String, dynamic> patch) =>
      ds.update(id, patch);

  @override
  Future<void> softDelete(String id) => ds.softDelete(id);

  @override
  Future<int> getCountByCommunity(
    String communityId, {
    bool excludeDeleted = true,
  }) {
    return ds.countByCommunity(
      communityId: communityId,
      excludeDeleted: excludeDeleted,
    );
  }
}
