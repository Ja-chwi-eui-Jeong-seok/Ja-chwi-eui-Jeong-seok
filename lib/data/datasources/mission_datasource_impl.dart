import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ja_chwi/data/datasources/mission_datasource.dart';
import 'package:ja_chwi/data/datasources/mission_date_util.dart';
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

    // 프로필의 mission_count를 1 증가시킵니다.
    await _firestore.collection('profiles').doc(userId).update({
      'mission_count': FieldValue.increment(1),
    });
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
  Future<Mission> fetchTodayMission(
    String userId, {
    DateTime? debugNow, // 테스트를 위한 시간 주입용 파라미터
  }) async {
    // 1. 전체 미션 개수를 가져옵니다. (미션 코드가 순환하기 위해 필요)
    final missionConfigDoc = await _firestore
        .collection('daily_mission_config')
        .doc('config')
        .get();
    if (!missionConfigDoc.exists) {
      throw Exception('미션 설정(`daily_mission_config/config`) 문서를 찾을 수 없습니다.');
    }
    final int totalMissions = missionConfigDoc.data()?['total_missions'] ?? 1;

    // 2. 유틸리티 함수를 사용하여 오늘의 미션 코드를 계산합니다.
    final int todayMissionCode = calculateTodayMissionCode(
      totalMissions: totalMissions,
      now: debugNow,
    );

    // 3. 계산된 코드로 오늘의 미션을 가져옵니다.
    final missionQuery = await _firestore
        .collection('mission')
        .where('missioncode', isEqualTo: todayMissionCode)
        .limit(1)
        .get();

    if (missionQuery.docs.isEmpty) {
      throw Exception(
        '오늘의 미션(코드: $todayMissionCode)을 찾을 수 없습니다. Firestore `mission` 컬렉션을 확인해주세요.',
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

  @override
  Future<List<Map<String, dynamic>>> fetchTodayMissionAchievers() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    // 1. 오늘 생성된 미션 문서를 가져옵니다.
    final missionSnapshot = await _firestore
        .collection('user_missions')
        .where('missioncreatedate', isGreaterThanOrEqualTo: startOfToday)
        .where('missioncreatedate', isLessThan: endOfToday)
        .orderBy('missioncreatedate', descending: false) // 먼저 완료한 순서
        .get();

    if (missionSnapshot.docs.isEmpty) {
      return [];
    }

    // 2. 각 미션 문서에서 userId와 완료 시간을 추출합니다.
    final achieversData = missionSnapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['missioncreatedate'] as Timestamp;
      return {
        'userId': data['userId'] as String,
        'completedAt': timestamp.toDate(),
      };
    }).toList();

    // 3. 각 userId로 character 정보를 가져옵니다.
    final List<Map<String, dynamic>> result = [];
    for (final achieverData in achieversData) {
      final userId = achieverData['userId'] as String;

      // 'profiles' 컬렉션에서 프로필 정보 가져오기
      final profileDoc = await _firestore
          .collection('profiles')
          .doc(userId)
          .get();

      if (profileDoc.exists) {
        result.add({
          ...profileDoc.data()!,
          ...achieverData,
        });
      }
    }
    return result;
  }
}
