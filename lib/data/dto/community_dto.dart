// data/dto/community_dto.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityDto {
  final int categoryCode;
  final int categoryDetailCode;
  // 문서 ID(doc.id)를 communityCode로 사용 (데이터 필드로는 저장하지 않음)
  final String communityCode;
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

  // firebase -> dto
  factory CommunityDto.fromFirebase(String id, Map<String, dynamic> d) {
    return CommunityDto(
      categoryCode: d['categoryCode'],
      categoryDetailCode: d['categoryDetailCode'],
      communityCode: id,
      communityDetail: d['communityDetail'],
      createUser: d['createUser'],
      communityName: d['communityName'],
      location: d['location'],
      communityCreateDate: d['communityCreateDate'],
      communityUpdateDate: d['communityUpdateDate'],
      communityDeleteDate: d['communityDeleteDate'],
      communityDeleteYn: d['communityDeleteYn'],
      communityDeleteNote: d['communityDeleteNote'],
    );
  }

  // 생성
  // 생성시간은 serverTimestamp
  Map<String, dynamic> toCreateMap() {
    return {
      'categoryCode': categoryCode,
      'categoryDetailCode': categoryDetailCode,
      'communityDetail': communityDetail,
      'createUser': createUser,
      'communityName': communityName,
      'location': location,
      'communityCreateDate': FieldValue.serverTimestamp(),
      'communityDeleteYn': false,
      //Timestamp.now()는 기기시간
      //'communityCode': communityCode, // doc.id 사용
      //'communityUpdateDate': communityUpdateDate,
      //'communityDeleteDate': communityDeleteDate,
      //'communityDeleteNote': communityDeleteNote,
    };
  }

  //수정
  Map<String, dynamic> toUpdateMap({
    String? communityName,
    String? comunityDetail,
    String? location,
  }) {
    return {
      if (communityName != null) 'communityName': communityName,
      if (communityDetail != null) 'communityDetail': communityDetail,
      if (location != null) 'location': location,
      'communityUpdateDate': FieldValue.serverTimestamp(),
    };
  }

  /// 삭제
  Map<String, dynamic> toDeleteMap({String? note}) {
    return {
      'communityDeleteYn': true,
      'communityDeleteNote': note,
      'communityDeleteDate': FieldValue.serverTimestamp(),
    };
  }
}
