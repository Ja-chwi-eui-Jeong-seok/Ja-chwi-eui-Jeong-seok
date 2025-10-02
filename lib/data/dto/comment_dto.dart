// lib/data/dto/comment_dto.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentDto {
  final String id; // doc.id
  final String communityId; // community_id
  final String uid; // uid
  final String noteDetail; // note_detail
  final int likeCount; // like_count
  final Timestamp createAt; // comment_create_date
  final Timestamp? updateAt; // comment_update_date
  final Timestamp? deleteAt; // comment_delete_date
  final bool deleteYn; // comment_delete_yn
  final List<String>? commentLog; // community_log (유지)

  CommentDto({
    required this.id,
    required this.communityId,
    required this.uid,
    required this.noteDetail,
    required this.likeCount,
    required this.createAt,
    this.updateAt,
    this.deleteAt,
    required this.deleteYn,
    this.commentLog,
  });

  //댓글 불러오기(firebase에서 읽기)
  factory CommentDto.fromFirebase(String id, Map<String, dynamic> d) {
    return CommentDto(
      id: id,
      communityId: d['community_id'] as String, //FK
      uid: d['uid'] as String,
      noteDetail: d['note_detail'] as String,
      likeCount: (d['like_count'] ?? 0) as int,
      createAt: d['comment_create_date'] as Timestamp,
      updateAt: d['comment_update_date'] as Timestamp?,
      deleteAt: d['comment_delete_date'] as Timestamp?,
      deleteYn: (d['comment_delete_yn'] ?? false) as bool,
      commentLog: (d['comment_log'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'community_id': communityId,
    'uid': uid,
    'note_detail': noteDetail,
    'like_count': likeCount,
    'comment_create_date': FieldValue.serverTimestamp(),
    'comment_delete_yn': false,
    if (commentLog != null) 'comment_log': commentLog,
  };

  Map<String, dynamic> toUpdateMap({
    String? noteDetail,
    List<String>? commentLog,
  }) => {
    if (noteDetail != null) 'note_detail': noteDetail,
    if (commentLog != null) 'comment_log': commentLog,
    'comment_update_date': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toDeleteMap() => {
    'comment_delete_yn': true,
    'comment_delete_date': FieldValue.serverTimestamp(),
  };

  CommentDto copyWith({
    String? noteDetail,
    int? likeCount,
    Timestamp? updateAt,
    Timestamp? deleteAt,
    bool? deleteYn,
    List<String>? commentLog,
  }) {
    return CommentDto(
      id: id,
      communityId: communityId,
      uid: uid,
      noteDetail: noteDetail ?? this.noteDetail,
      likeCount: likeCount ?? this.likeCount,
      createAt: createAt,
      updateAt: updateAt ?? this.updateAt,
      deleteAt: deleteAt ?? this.deleteAt,
      deleteYn: deleteYn ?? this.deleteYn,
      commentLog: commentLog ?? this.commentLog,
    );
  }
}
