import 'package:flutter_riverpod/flutter_riverpod.dart';

// 답글 모드 관련 Provider들
enum ReplyMode { none, replying }

class ReplyModeData {
  final String parentCommentId;
  final String parentCommentUid;
  final String parentCommentNickname;

  ReplyModeData({
    required this.parentCommentId,
    required this.parentCommentUid,
    required this.parentCommentNickname,
  });

  @override
  String toString() {
    return 'ReplyModeData(parentCommentId: $parentCommentId, parentCommentUid: $parentCommentUid, parentCommentNickname: $parentCommentNickname)';
  }
}

final replyModeProvider = StateProvider<ReplyMode>((ref) => ReplyMode.none);
final replyModeDataProvider = StateProvider<ReplyModeData?>((ref) => null);
