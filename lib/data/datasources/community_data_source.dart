import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/common/page_result.dart';
import 'package:ja_chwi/data/dto/community_dto.dart';

abstract interface class CommunityDataSource {
  Future<PagedResult<CommunityDto>> fetchCommunities({
    required int categoryCode,
    required int categoryDetailCode,
    String? location, //아직 셋팅안됌
    int limit, //기본페이지 크기 10
    DocumentSnapshot? startAfterDoc, //페이징커서
    bool orderDesc, //차순정렬
  });
  //게시글생성
  Future<String> createCommunity(CommunityDto dto);

  //업데이트
  Future<void> updateCommunity({
    required String communityCode, //doc.id
    required Map<String, dynamic> patch,
  });

  //삭제
  Future<void> softDeleteCommunity({
    required String communityCode, //doc.id
    String? note,
  });
}
