import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/domain/repositories/community_repository.dart';

class FetchCommunities {
  final CommunityRepository repo;
  FetchCommunities(this.repo);

  Future<(List<Community> items, DocumentSnapshot? lastDoc, bool hasMore)>
  call({
    required int categoryCode,
    required int categoryDetailCode,
    int limit = 10,
    DocumentSnapshot? startAfter,
    bool desc = true,
  }) async {
    final page = await repo.fetch(
      categoryCode: categoryCode,
      categoryDetailCode: categoryDetailCode,
      limit: limit,
      startAfter: startAfter,
      desc: desc,
    );
    return (page.items, page.lastDoc, page.hasMore);
  }
}
