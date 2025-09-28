import 'package:ja_chwi/data/datasources/block_datasource.dart';
import 'package:ja_chwi/domain/entities/block_entity.dart';
import 'package:ja_chwi/domain/repositories/block_repository.dart';

class BlockRepositoryImpl implements BlockRepository {
  final BlockDataSource remoteDataSource;

  BlockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> blockUser({
    required String userId,
    required String blockedBy,
    String? reason,
  }) async {
    await remoteDataSource.blockUser(userId: userId, blockedBy: blockedBy, reason: reason);
  }

  @override
  Future<void> unblockUser(String blockId) async {
    await remoteDataSource.unblockUser(blockId);
  }

  @override
  Future<List<BlockEntity>> fetchBlockedUsers() async {
    final models = await remoteDataSource.fetchBlockedUsers();
    return models.map((e) => e.toDomain()).toList();
  }

    @override
  Future<List<BlockEntity>> fetchBlockedUsersByMe(String myUid) async {
    final models = await remoteDataSource.fetchBlockedUsersByMe(myUid);
    return models.map((m) => m.toDomain()).toList();
  }
}
