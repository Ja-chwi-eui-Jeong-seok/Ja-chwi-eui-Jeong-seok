import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ja_chwi/data/datasources/mission_datasource.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_model.dart';

class MissionDataSourceImpl implements MissionDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MissionDataSourceImpl(this._firestore, this._storage);

  String _generateDocId(String uid) {
    final today = DateTime.now();
    return '${uid}_${today.year}-${today.month}-${today.day}';
  }

  @override
  Future<bool> hasCompletedMissionToday(String userId) async {
    final docId = _generateDocId(userId);
    final doc = await _firestore.collection('user_missions').doc(docId).get();
    return doc.exists;
  }

  @override
  Future<List<String>> uploadPhotos(String userId, List<dynamic> photos) async {
    final List<String> photoUrls = [];

    for (var photo in photos) {
      if (photo is String) {
        photoUrls.add(photo);
      } else if (photo is XFile) {
        final file = File(photo.path);
        final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child('mission_photos').child(fileName);
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        photoUrls.add(downloadUrl);
      }
    }
    return photoUrls;
  }

  @override
  Future<void> createMission({
    required String userId,
    required Map<String, dynamic> missionData,
  }) async {
    final docId = _generateDocId(userId);
    final dataWithTimestamp = {
      ...missionData,
      'missioncreatedate': FieldValue.serverTimestamp(),
      'userId': userId,
    };
    await _firestore
        .collection('user_missions')
        .doc(docId)
        .set(dataWithTimestamp);
  }

  @override
  Future<void> updateMission({
    required String userId,
    required Map<String, dynamic> missionData,
  }) async {
    final docId = _generateDocId(userId);
    // 업데이트 시에는 생성 날짜와 userId를 제외합니다.
    final dataToUpdate = Map<String, dynamic>.from(missionData)
      ..remove('missioncreatedate')
      ..remove('userId');

    await _firestore
        .collection('user_missions')
        .doc(docId)
        .update(dataToUpdate);
  }

  @override
  Future<Mission> fetchTodayMission() async {
    // --- 개발용 임시 코드 ---
    // 로그인 여부와 관계없이 UI 확인을 위해 미션 코드 1번을 강제로 가져옵니다.
    // TODO: 로그인 기능이 완성되면 이 코드를 삭제하고 아래 주석 처리된 원본 코드를 복구해야 합니다.
    const int tempMissionCode = 1;
    final missionQuery = await _firestore
        .collection('mission')
        .where('missioncode', isEqualTo: tempMissionCode)
        .limit(1)
        .get();

    if (missionQuery.docs.isEmpty) {
      throw Exception(
        '임시 코드에 해당하는 미션(코드: $tempMissionCode)을 찾을 수 없습니다. Firestore `mission` 컬렉션에 missioncode가 1인 문서가 있는지 확인해주세요.',
      );
    }
    return Mission.fromFirestore(missionQuery.docs.first);
  }

  @override
  Stream<List<Map<String, dynamic>>> fetchUserMissions(String userId) {
    // userId는 이미 UseCase/Repository에서 검증되었으므로 여기서는 바로 사용
    return _firestore
        .collection('user_missions')
        .where('userId', isEqualTo: userId)
        .orderBy('missioncreatedate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList(),
        );
  }
}
