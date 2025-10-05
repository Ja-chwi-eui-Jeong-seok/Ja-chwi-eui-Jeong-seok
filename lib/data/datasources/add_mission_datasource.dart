import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/add_mission_entity.dart';

class AddMissionDataSource {
  final FirebaseFirestore firestore;

  AddMissionDataSource(this.firestore);

  Stream<List<AddMissionEntity>> getMissions() {
    return firestore
        .collection('mission')
        .orderBy('missioncode')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return AddMissionEntity(
                id: doc.id,
                missionCode: data['missioncode'],
                missionTag: data['missiontag'],
                missionTitle: data['missiontitle']
              );
            }).toList());
  }

Future<void> addMission(String tag, String title) async {
  final missionsRef = firestore.collection('mission');

  // 최대 mission_code 조회
  final snapshot = await missionsRef
      .orderBy('missioncode', descending: true)
      .limit(1)
      .get(); // QuerySnapshot 반환

  int newCode = 1;
  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs.first.data() ;
    newCode = (data['missioncode'] ?? 0) + 1;
  }

  final newDoc = missionsRef.doc();
  await newDoc.set({
    'missioncode': newCode,
    'missiontag': tag,
    'missiontitle': title
  });
}



  Future<void> updateMission(String docId, String tag, String title) async {
    final docRef = firestore.collection('mission').doc(docId);
    await docRef.update({
      'missiontag': tag,
      'missiontitle': title
    });
  }

  Future<void> deleteMission(String docId) async {
    final docRef = firestore.collection('mission').doc(docId);
    await docRef.delete();
  }
}
