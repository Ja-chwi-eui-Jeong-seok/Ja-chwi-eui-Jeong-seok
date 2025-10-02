import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityDto {
  final int categoryCode;
  final int categoryDetailCode;
  final String communityCode; // doc.id
  final String communityDetail;
  final String createUser;
  final String communityName;
  final String location;
  final Timestamp communityCreateDate;
  final Timestamp? communityUpdateDate;
  final Timestamp? communityDeleteDate;
  final bool communityDeleteYn;
  final String? communityDeleteNote;

  CommunityDto({
    required this.categoryCode,
    required this.categoryDetailCode,
    required this.communityCode,
    required this.communityDetail,
    required this.createUser,
    required this.communityName,
    required this.location,
    required this.communityCreateDate,
    this.communityUpdateDate,
    this.communityDeleteDate,
    required this.communityDeleteYn,
    this.communityDeleteNote,
  });

  /// Firestore → DTO 변환
  factory CommunityDto.fromFirebase(String id, Map<String, dynamic> d) {
    return CommunityDto(
      categoryCode: d['category_code'],
      categoryDetailCode: d['category_detail_code'],
      communityCode: id,
      communityDetail: d['community_detail'],
      createUser: d['create_user'],
      communityName: d['community_name'],
      location: d['location'],
      communityCreateDate: d['community_create_date'],
      communityUpdateDate: d['community_update_date'],
      communityDeleteDate: d['community_delete_date'],
      communityDeleteYn: d['community_delete_yn'],
      communityDeleteNote: d['community_delete_note'],
    );
  }

  /// Firestore 저장용 (생성)
  Map<String, dynamic> toCreateMap() {
    return {
      'category_code': categoryCode,
      'category_detail_code': categoryDetailCode,
      'community_detail': communityDetail,
      'create_user': createUser,
      'community_name': communityName,
      'location': location,
      'community_create_date': FieldValue.serverTimestamp(),
      'community_delete_yn': false,
    };
  }

  /// Firestore 수정용
  Map<String, dynamic> toUpdateMap({
    String? communityName,
    String? communityDetail,
    String? location,
  }) {
    return {
      if (communityName != null) 'community_name': communityName,
      if (communityDetail != null) 'community_detail': communityDetail,
      if (location != null) 'location': location,
      'community_update_date': FieldValue.serverTimestamp(),
    };
  }

  /// Firestore 삭제 처리용
  Map<String, dynamic> toDeleteMap({String? note}) {
    return {
      'community_delete_yn': true,
      'community_delete_note': note,
      'community_delete_date': FieldValue.serverTimestamp(),
    };
  }
}
