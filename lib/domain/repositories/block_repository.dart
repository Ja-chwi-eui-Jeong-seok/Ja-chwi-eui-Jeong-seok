import 'package:ja_chwi/domain/entities/block_entity.dart';

abstract class BlockRepository {
  Future<void> blockUser({
    required String userId,
    required String blockedBy,
    String? reason,
  });

  Future<void> unblockUser(String blockId);

  Future<List<BlockEntity>> fetchBlockedUsers();
//내가 차단한 리스트 
  Future<List<BlockEntity>> fetchBlockedUsersByMe(String myUid);
}
