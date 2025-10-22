import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
final blockedUsersProvider = StreamProvider<List<String>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value(<String>[]);

  // 실시간으로 내가 차단한 사용자 목록을 스트리밍
  final stream = FirebaseFirestore.instance
      .collection('blocks')
      .where('blockedBy', isEqualTo: currentUser.uid)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => (doc.data()['userId'] as String?) ?? '')
            .where((uid) => uid.isNotEmpty)
            .toList(),
      );

  return stream;
});
