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
  final Timestamp communityCreatedate;
  final Timestamp? communityUpdatedate;
  final Timestamp? communityDeletedate;
  final bool communityDeleteyn;
  final String? communityDeletenote;

  CommunityDto({
    required this.categoryCode,
    required this.categoryDetailCode,
    required this.communityCode,
    required this.communityDetail,
    required this.createUser,
    required this.communityName,
    required this.location,
    required this.communityCreatedate,
    this.communityUpdatedate,
    this.communityDeletedate,
    required this.communityDeleteyn,
    this.communityDeletenote,
  });

  factory CommunityDto.fromFirebase(String id, Map<String, dynamic> d) {
    return CommunityDto(
      categoryCode: d['categoryCode'],
      categoryDetailCode: d['categoryDetailCode'],
      communityCode: id,
      communityDetail: d['communityDetail'],
      createUser: d['createUser'],
      communityName: d['communityName'],
      location: d['location'],
      communityCreatedate: d['communityCreatedate'],
      communityUpdatedate: d['communityUpdatedate'],
      communityDeletedate: d['communityDeletedate'],
      communityDeleteyn: d['communityDeleteyn'],
      communityDeletenote: d['communityDeletenote'],
    );
  }
}
