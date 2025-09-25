// data/repositories/community_repository_impl.dart
import 'package:ja_chwi/domain/repositories/community_repository.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/data/datasources/community_data_source.dart';
import 'package:ja_chwi/data/dto/community_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityDataSource ds;
  CommunityRepositoryImpl(this.ds);

  // DTO -> Entity 변환 ( 매퍼 대신 사용)
  Community _toEntity(CommunityDto d) {
    return Community(
      id: d.communityCode,
      categoryCode: d.categoryCode,
      categoryDetailCode: d.categoryDetailCode,
      communityName: d.communityName,
      communityDetail: d.communityDetail,
      createUser: d.createUser,
      location: d.location,
      communityCreateDate: d.communityCreateDate.toDate(),
      communityUpdateDate: d.communityUpdateDate?.toDate(),
      communityDeleteDate: d.communityDeleteDate?.toDate(),
      communityDeleteYn: d.communityDeleteYn,
      communityDeleteNote: d.communityDeleteNote,
    );
  }

  // Entity -> DTO (생성 시에만 필요)
  CommunityDto _toDtoForCreate(Community e) {
    return CommunityDto(
      categoryCode: e.categoryCode,
      categoryDetailCode: e.categoryDetailCode,
      communityCode: '', // add()로 생성되므로 무시
      communityDetail: e.communityDetail,
      createUser: e.createUser,
      communityName: e.communityName,
      location: e.location,
      communityCreateDate: Timestamp.now(),
      communityDeleteYn: false,
      communityUpdateDate: null,
      communityDeleteDate: null,
      communityDeleteNote: null,
    );
  }

  @override
  Future<Community?> getById(String id) async {
    final d = await ds.getCommunityById(id);
    if (d == null) return null;
    return Community(
      id: d.communityCode,
      categoryCode: d.categoryCode,
      categoryDetailCode: d.categoryDetailCode,
      communityName: d.communityName,
      communityDetail: d.communityDetail,
      createUser: d.createUser,
      location: d.location,
      communityCreateDate: d.communityCreateDate.toDate(),
      communityUpdateDate: d.communityUpdateDate?.toDate(),
      communityDeleteDate: d.communityDeleteDate?.toDate(),
      communityDeleteYn: d.communityDeleteYn,
      communityDeleteNote: d.communityDeleteNote,
    );
  }

  //게시글생성
  @override
  Future<String> create(Community input) async {
    final dto = _toDtoForCreate(input);
    return ds.createCommunity(dto);
  }

  //게시글불러오기
  @override
  Future<PagedCommunity> fetch({
    required int categoryCode,
    required int categoryDetailCode,
    required String location,
    int limit = 10,
    DocumentSnapshot? startAfter,
    bool desc = true,
  }) async {
    final page = await ds.fetchCommunities(
      categoryCode: categoryCode,
      categoryDetailCode: categoryDetailCode,
      location: location, //동작구 넣기 ui에서
      limit: limit,
      startAfterDoc: startAfter,
      orderDesc: desc,
    );
    final items = page.items.map(_toEntity).toList();
    return PagedCommunity(items, page.lastDoc, page.hasMore);
  }

  //업데이트
  @override
  Future<void> update(String id, Map<String, dynamic> patch) {
    return ds.updateCommunity(communityCode: id, patch: patch);
  }

  //삭제
  @override
  Future<void> softDelete(String id, {String? note}) {
    return ds.softDeleteCommunity(communityCode: id, note: note);
  }
}
