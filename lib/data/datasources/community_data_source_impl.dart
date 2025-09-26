import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/datasources/community_data_source.dart';
import 'package:ja_chwi/data/dto/community_dto.dart';

class CommunityDataSourceImpl implements CommunityDataSource {
  final FirebaseFirestore fs;
  CommunityDataSourceImpl(this.fs);

  CollectionReference<Map<String, dynamic>> get col =>
      fs.collection('communitylist');

  // 생성
  @override
  Future<String> createCommunity(CommunityDto dto) async {
    final ref = await col.add(dto.toCreateMap());
    return ref.id;
  }

  //조회(상세피이지)
  @override
  Future<CommunityDto?> getCommunityById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    return CommunityDto.fromFirebase(doc.id, doc.data()!);
  }

  // 조회(페이징)
  @override
  Future<PagedResult<CommunityDto>> fetchCommunities({
    required int categoryCode,
    required int categoryDetailCode,
    required String location,
    int limit = 10,
    DocumentSnapshot<Object?>? startAfterDoc,
    bool orderDesc = true,
  }) async {
    Query<Map<String, dynamic>> q = col
        .where('category_code', isEqualTo: categoryCode)
        .where('category_detail_code', isEqualTo: categoryDetailCode)
        .where('community_delete_yn', isEqualTo: false);

    //날짜 임시로 동작구
    if (location != null && location.isNotEmpty) {
      if (kDebugMode) {
        print('위치 : $location');
      }
      q = q.where('location', isEqualTo: location);
    } else {
      if (kDebugMode) {
        print('위치 : $location');
      }
    }

    // 1차: 날짜, 2차: 문서ID로 안정 정렬
    q = q
        .orderBy('community_create_date', descending: orderDesc)
        .orderBy(FieldPath.documentId, descending: orderDesc)
        .limit(limit);

    if (startAfterDoc != null) {
      q = q.startAfterDocument(startAfterDoc);
    }

    final snap = await q.get();
    final items = snap.docs
        .map((d) => CommunityDto.fromFirebase(d.id, d.data()))
        .toList();
    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;

    return PagedResult(
      items: items,
      lastDoc: lastDoc,
      hasMore: snap.docs.length == limit,
    );
  }

  // 소프트 삭제
  @override
  Future<void> softDeleteCommunity({
    required String communityCode,
    String? note,
  }) {
    return col.doc(communityCode).update({
      'community_delete_yn': true,
      'community_delete_note': note,
      'community_delete_date': FieldValue.serverTimestamp(),
    });
  }

  // 부분 업데이트
  @override
  Future<void> updateCommunity({
    required String communityCode,
    required Map<String, dynamic> patch,
  }) {
    return col.doc(communityCode).update(patch);
  }
}
