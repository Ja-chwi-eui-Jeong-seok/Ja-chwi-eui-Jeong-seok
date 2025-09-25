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
  Future<String> create(Community input);
  Future<PagedCommunity> fetch({
    required int categoryCode,
    required int categoryDetailCode,
    int limit,
    DocumentSnapshot? startAfter,
    bool desc,
  });

  Future<void> update(String id, Map<String, dynamic> patch);
  Future<void> softDelete(String id, {String? note});
}
