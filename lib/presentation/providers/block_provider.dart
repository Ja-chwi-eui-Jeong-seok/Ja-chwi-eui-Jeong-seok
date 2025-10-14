import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/block_datasource.dart';
import 'package:ja_chwi/data/repositories/block_repository_impl.dart';

final blockRepositoryProvider = Provider<BlockRepositoryImpl>((ref) {
  return BlockRepositoryImpl(remoteDataSource: FirebaseBlockDataSource());
});

final blockUserActionProvider =
    Provider<
      Future<String?> Function({
        required String myUid,
        required String targetUid,
        String? reason,
      })
    >((ref) {
      return ({
        required String myUid,
        required String targetUid,
        String? reason,
      }) async {
        try {
          await ref
              .read(blockRepositoryProvider)
              .remoteDataSource
              .blockUser(userId: targetUid, blockedBy: myUid, reason: reason);
          return null; // 성공
        } catch (e) {
          return '차단 실패: $e';
        }
      };
    });

// 현재 사용자가 차단한 유저 목록을 가져오는 provider
final blockedUsersProvider = FutureProvider<List<String>>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return [];
  
  try {
    final blockedUsers = await ref
        .read(blockRepositoryProvider)
        .fetchBlockedUsersByMe(currentUser.uid);
    return blockedUsers.map((block) => block.userId).toList();
  } catch (e) {
    return [];
  }
});
