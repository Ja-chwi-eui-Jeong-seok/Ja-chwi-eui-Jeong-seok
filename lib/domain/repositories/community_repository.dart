import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/community.dart';

//페이징전용
class PagedCommunity {
  final List<Community> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
  const PagedCommunity(this.items, this.lastDoc, this.hasMore);
}

abstract interface class CommunityRepository {
  //생성
  Future<String> create(Community input);
  //단건조회
  Future<Community?> getById(String id);
  //조회 페이징
  Future<PagedCommunity> fetch({
    required int categoryCode,
    required int categoryDetailCode,
    String? location,
    int limit,
    DocumentSnapshot? startAfter,
    bool desc,
  });
  //업데이트
  Future<void> update(String id, Map<String, dynamic> patch);
  //삭제(delete값 true)
  Future<void> softDelete(String id, {String? note});
}
