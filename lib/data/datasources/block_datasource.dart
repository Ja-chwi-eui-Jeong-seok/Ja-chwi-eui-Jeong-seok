import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/models/block_model.dart';

abstract class BlockDataSource {
  Future<void> blockUser({
    required String userId,
    required String blockedBy,
    String? reason,
  });

  Future<void> unblockUser(String blockId);

  Future<List<BlockModel>> fetchBlockedUsers();
  // 추가: 내가 블록한 사람 조회
  Future<List<BlockModel>> fetchBlockedUsersByMe(String myUid);
}
class FirebaseBlockDataSource implements BlockDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> blockUser({
    required String userId,
    required String blockedBy,
    String? reason,
  }) async {
    await firestore.collection('blocks').add({
      'userId': userId,
      'blockedBy': blockedBy,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unblockUser(String blockId) async {
    await firestore.collection('blocks').doc(blockId).delete();
  }

  @override
  Future<List<BlockModel>> fetchBlockedUsers() async {
    final snapshot = await firestore.collection('blocks').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BlockModel(
        id: doc.id,
        userId: data['userId'],
        blockedBy: data['blockedBy'],
        reason: data['reason'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }
  //내가 차단한 리스트 
  Future<List<BlockModel>> fetchBlockedUsersByMe(String myUid) async {
      print('fetchBlockedUsersByMe 호출, myUid: $myUid'); // ✅ 확인용 출력

  final snapshot = await firestore
      .collection('blocks')
      .where('blockedBy', isEqualTo: myUid)
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    final timestamp = data['createdAt'] as Timestamp?;
    return BlockModel(
      id: doc.id,
      userId: data['userId'] as String,
      blockedBy: data['blockedBy'] as String,
      reason: data['reason'] as String?,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }).toList();
}

}
