import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/datasources/community_data_source.dart';
import 'package:ja_chwi/data/dto/community_dto.dart';

class CommunityDataSourceImpl implements CommunityDataSource {
  final FirebaseFirestore fs;
  CommunityDataSourceImpl(this.fs);

  CollectionReference<Map<String, dynamic>> get col =>
      fs.collection('communitylist');

  //게시글생성
  @override
  Future<String> createCommunity(CommunityDto dto) async {
    final ref = await col.add(dto.toCreateMap());
    return ref.id;
  }

  //게시글 불러오기
  @override
  Future<PagedResult<CommunityDto>> fetchCommunities({
    required int categoryCode,
    required int categoryDetailCode,
    String? location,
    int limit = 10,
    DocumentSnapshot<Object?>? startAfterDoc,
    bool orderDesc = true,
  }) async {
    Query<Map<String, dynamic>> q = col
        .where('categoryCode', isEqualTo: categoryCode)
        .where('categoryDetailCode', isEqualTo: categoryDetailCode)
        .where('communityDeleteYn', isEqualTo: false)
        .orderBy('communityCreateDate', descending: orderDesc);

    if (startAfterDoc != null) {
      q = q.startAfterDocument(startAfterDoc); //다음페이지
    }

    final snap = await q.get();
    final items = snap.docs
        .map((d) => CommunityDto.fromFirebase(d.id, d.data()))
        .toList();
    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;

    return PagedResult(
      items: items,
      lastDoc: lastDoc,
      hasMore: snap.docs.length == limit, //최대에 도달하면 true
    );
  }

  //삭제처리
  @override
  Future<void> softDeleteCommunity({
    required String communityCode,
    String? note,
  }) {
    return col.doc(communityCode).update({
      'communityDeleteYn': true,
      'communityDeleteNote': note,
      'communityDeleteDate': FieldValue.serverTimestamp(),
    });
  }

  //업데이트
  @override
  Future<void> updateCommunity({
    required String communityCode,
    required Map<String, dynamic> patch,
  }) {
    return col.doc(communityCode).update(patch);
  }
}
