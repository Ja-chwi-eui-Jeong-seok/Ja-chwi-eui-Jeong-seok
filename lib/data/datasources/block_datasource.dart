import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/models/block_model.dart';

/// 🔹 추상 데이터소스 정의 (인터페이스 역할)
abstract class BlockDataSource {
  Future<void> blockUser({
    required String userId,
    required String blockedBy,
    String? reason,
  });

  Future<void> unblockUser(String blockId);

  Future<List<BlockModel>> fetchBlockedUsers();

  Future<List<BlockModel>> fetchBlockedUsersByMe(String myUid);
}

/// 🔹 실제 Firestore 구현부
class FirebaseBlockDataSource implements BlockDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> blockUser({
    required String userId,
    required String blockedBy,
    String? reason,
  }) async {
    // ✅ 중복 차단 방지 로직 추가
    final existing = await firestore
        .collection('blocks')
        .where('userId', isEqualTo: userId)
        .where('blockedBy', isEqualTo: blockedBy)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await firestore.collection('blocks').add({
        'userId': userId,
        'blockedBy': blockedBy,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("차단 완료: $userId");
    } else {
      print("이미 차단된 사용자입니다: $userId");
    }
  }

  @override
  Future<void> unblockUser(String blockId) async {
    await firestore.collection('blocks').doc(blockId).delete();
    print("차단 해제 완료: $blockId");
  }

  @override
  Future<List<BlockModel>> fetchBlockedUsers() async {
    final snapshot = await firestore
        .collection('blocks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;
      return BlockModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        blockedBy: data['blockedBy'] ?? '',
        reason: data['reason'] ?? '',
        createdAt: timestamp?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<List<BlockModel>> fetchBlockedUsersByMe(String myUid) async {
    print('📡 fetchBlockedUsersByMe 호출, myUid: $myUid');

    final snapshot = await firestore
        .collection('blocks')
        .where('blockedBy', isEqualTo: myUid)
        .orderBy('createdAt', descending: true)
        .get();

    print('쿼리 결과 docs 수: ${snapshot.docs.length}');

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;
      return BlockModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        blockedBy: data['blockedBy'] ?? '',
        reason: data['reason'] ?? '',
        createdAt: timestamp?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}
