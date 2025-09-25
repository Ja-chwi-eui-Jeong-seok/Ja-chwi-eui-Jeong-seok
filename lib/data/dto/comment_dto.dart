// lib/data/dto/comment_dto.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentDto {
  final String id;
  final String communityId;
  final String uid;
  final String nickName;
  final String noteDetail;
  final int likeCount;
  final bool moderated;
  final List<String> violations;
  final Timestamp createAt;
  final Timestamp? updateAt;
  final Timestamp? deleteAt;
  final bool deleteYn;

  CommentDto({
    required this.id,
    required this.communityId,
    required this.uid,
    required this.nickName,
    required this.noteDetail,
    required this.likeCount,
    required this.moderated,
    required this.violations,
    required this.createAt,
    this.updateAt,
    this.deleteAt,
    required this.deleteYn,
  });

  factory CommentDto.fromFirebase(String id, Map<String, dynamic> d) {
    return CommentDto(
      id: id,
      communityId: d['community_id'],
      uid: d['uid'],
      nickName: d['nick_name'],
      noteDetail: d['note_detail'],
      likeCount: (d['like_count'] ?? 0) as int,
      moderated: (d['moderated'] ?? false) as bool,
      violations: (d['violations'] as List?)?.cast<String>() ?? const [],
      createAt: d['community_create_date'],
      updateAt: d['community_update_date'],
      deleteAt: d['community_delete_date'],
      deleteYn: d['community_delete_yn'] ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'community_id': communityId,
    'uid': uid,
    'nick_name': nickName,
    'note_detail': noteDetail,
    'like_count': likeCount,
    'moderated': moderated,
    'violations': violations,
    'community_create_date': FieldValue.serverTimestamp(),
    'community_delete_yn': false,
  };

  Map<String, dynamic> toUpdateMap({String? noteDetail}) => {
    if (noteDetail != null) 'note_detail': noteDetail,
    'community_update_date': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toDeleteMap() => {
    'community_delete_yn': true,
    'community_delete_date': FieldValue.serverTimestamp(),
  };
}
