// data/datasources/report_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/report_entity.dart';

abstract class ReportDataSource {
  Future<void> reportUser({
    required String userId,
    required String targetId,
    required String reason,
  });

  Future<List<ReportEntity>> fetchReportsByMe(String myUid);
}

class FirebaseReportDataSource implements ReportDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> reportUser({
    required String userId,
    required String targetId,
    required String reason,
  }) async {
    await firestore.collection('reports').add({
      'userId': userId,
      'targetId': targetId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<ReportEntity>> fetchReportsByMe(String myUid) async {
  print('fetchReportsByMe 호출, myUid: $myUid'); // ✅ 확인용 출력
  
    final snapshot = await firestore
        .collection('reports')
        .where('userId', isEqualTo: myUid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ReportEntity(
        id: doc.id,
        userId: data['userId'],
        targetId: data['targetId'],
        reason: data['reason'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }
}
