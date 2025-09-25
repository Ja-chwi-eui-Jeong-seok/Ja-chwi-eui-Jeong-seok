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
    nickName: d.nickName,
    noteDetail: d.noteDetail,
    likeCount: d.likeCount,
    moderated: d.moderated,
    violations: d.violations,
    createAt: d.createAt.toDate(),
    updateAt: d.updateAt?.toDate(),
    deleteAt: d.deleteAt?.toDate(),
    deleteYn: d.deleteYn,
  );

  @override
  Future<String> create(Comment input) {
    final dto = CommentDto(
      id: '',
      communityId: input.communityId,
      uid: input.uid,
      nickName: input.nickName,
      noteDetail: input.noteDetail,
      likeCount: input.likeCount,
      moderated: input.moderated,
      violations: input.violations,
      createAt: Timestamp.now(),
      updateAt: null,
      deleteAt: null,
      deleteYn: false,
    );
    return ds.create(dto);
  }

  @override
  Future<void> softDelete(String id) => ds.softDelete(id);

  @override
  Future<void> update(String id, Map<String, dynamic> patch) =>
      ds.update(id, patch);

  @override
  Future<void> incLike(String id, int delta) => ds.incLike(id, delta);

  @override
  Future<({List<Comment> items, DocumentSnapshot? lastDoc, bool hasMore})>
  fetchByCommunity({
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
    return (
      items: page.items.map(_toEntity).toList(),
      lastDoc: page.lastDoc,
      hasMore: page.hasMore,
    );
  }
}
