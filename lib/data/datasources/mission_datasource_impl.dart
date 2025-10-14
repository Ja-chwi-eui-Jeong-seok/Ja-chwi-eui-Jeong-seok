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

    // 프로필의 mission_count를 1 증가
    await _firestore.collection('profiles').doc(userId).update({
      'mission_count': FieldValue.increment(1),
    });
  }

  @override
  Future<void> updateMission({
    required String userId,
    required String docId,
    required Map<String, dynamic> missionData,
  }) async {
    // 업데이트 시에는 생성 날짜와 userId를 제외
    final dataToUpdate =
        Map<String, dynamic>.from(missionData) // 복사본 생성
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
    DateTime? debugNow,
  }) async {
    // 1. 전체 미션 개수
    final missionConfigDoc = await _firestore
        .collection('daily_mission_config')
        .doc('config')
        .get();
    if (!missionConfigDoc.exists) {
      throw Exception('미션 설정(`daily_mission_config/config`) 문서를 찾을 수 없습니다.');
    }
    final int totalMissions = missionConfigDoc.data()?['total_missions'] ?? 1;

    // 2. 유틸리티 함수를 사용하여 오늘의 미션 코드를 계산
    final int todayMissionCode = calculateTodayMissionCode(
      totalMissions: totalMissions,
      now: debugNow,
    );

    // 3. 계산된 코드로 오늘의 미션 가져옴
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
  Future<List<Map<String, dynamic>>> fetchWeeklyMissionRankers(
    DateTime dateForWeek,
    String dongName,
  ) async {
    // 1. 주어진 날짜가 속한 주의 시작(월요일)과 끝(일요일)을 계산
    final startOfWeek = dateForWeek.subtract(
      Duration(days: dateForWeek.weekday - 1),
    );
    final startOfMonday = DateTime.utc(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    // 일요일 23:59:59까지 포함하도록 수정
    final endOfWeek = startOfMonday.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    // 2. 같은 dongName을 가진 사용자들의 ID를 가져옴
    final profileSnapshot = await _firestore
        .collection('profiles')
        .where('dongName', isEqualTo: dongName)
        .get();

    if (profileSnapshot.docs.isEmpty) {
      return []; // 같은 동네 사용자가 없으면 빈 목록 반환
    }
    final dongUserIds = profileSnapshot.docs.map((doc) => doc.id).toList();

    // 3. 해당 주에, 같은 동네 사용자들이 생성한 모든 미션을 가져옴
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> allMissionDocs = [];
    const chunkSize = 30;

    for (var i = 0; i < dongUserIds.length; i += chunkSize) {
      final chunk = dongUserIds.sublist(
        i,
        i + chunkSize > dongUserIds.length ? dongUserIds.length : i + chunkSize,
      );
      if (chunk.isEmpty) continue;

      final missionSnapshot = await _firestore
          .collection('user_missions')
          .where('userId', whereIn: chunk)
          .where('missioncreatedate', isGreaterThanOrEqualTo: startOfMonday)
          .where('missioncreatedate', isLessThanOrEqualTo: endOfWeek)
          .get();
      allMissionDocs.addAll(missionSnapshot.docs);
    }

    if (allMissionDocs.isEmpty) {
      return [];
    }

    // 3. 사용자별로 미션 개수와 마지막 미션 완료 시간을 집계함
    final Map<String, Map<String, dynamic>> userStats = {};
    for (final doc in allMissionDocs) {
      final data = doc.data();
      final userId = data['userId'] as String;
      final completedAt = (data['missioncreatedate'] as Timestamp).toDate();

      userStats.update(
        userId,
        (value) {
          final newCount = (value['count'] as int) + 1;
          final lastDate = (value['lastCompleted'] as DateTime);
          return {
            'count': newCount,
            'lastCompleted': completedAt.isAfter(lastDate)
                ? completedAt
                : lastDate,
          };
        },
        ifAbsent: () => {'count': 1, 'lastCompleted': completedAt},
      );
    }

    // 4. 사용자 프로필 정보를 가져와 Map으로 변환
    final userIds = userStats.keys.toList();
    if (userIds.isEmpty) return [];

    final profiles = await _fetchProfilesInChunks(userIds);

    // 5. userStats를 기준으로 rankers 목록을 생성하고 프로필 정보를 결합
    final List<Map<String, dynamic>> rankers = [];
    for (final userId in userIds) {
      final profileData = profiles[userId] ?? {}; // 프로필이 없으면 빈 맵
      rankers.add({
        'nickname': profileData['nickname'], // null일 수 있음
        'imageFullUrl': profileData['imageFullUrl'], // null일 수 있음
        'missionCount': profileData['mission_count'] ?? 0,
        'userId': userId,
        'weekCount': userStats[userId]!['count'],
        'lastCompleted': userStats[userId]!['lastCompleted'],
      });
    }

    // 6. 정렬: 1. 주간 미션 개수(내림차순), 2. 마지막 완료일(오름차순 - 먼저 한 사람이 위로)
    rankers.sort((a, b) {
      final countCompare = (b['weekCount'] as int).compareTo(
        a['weekCount'] as int,
      );
      if (countCompare != 0) return countCompare;
      return (a['lastCompleted'] as DateTime).compareTo(
        a['lastCompleted'] as DateTime,
      );
    });

    return rankers;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserMissionsForWeek({
    required String userId,
    required DateTime dateForWeek,
  }) async {
    // 1. 주어진 날짜가 속한 주의 시작(월요일)과 끝(일요일)을 계산
    final startOfWeek = dateForWeek.subtract(
      Duration(days: dateForWeek.weekday - 1),
    );
    final startOfMonday = DateTime.utc(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfMonday.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    // 2. 해당 주에 특정 사용자가 생성한 모든 미션을 가져옴
    final missionSnapshot = await _firestore
        .collection('user_missions')
        .where('userId', isEqualTo: userId)
        .where('missioncreatedate', isGreaterThanOrEqualTo: startOfMonday)
        .where('missioncreatedate', isLessThanOrEqualTo: endOfWeek)
        .orderBy('missioncreatedate', descending: true) // 최신순으로 정렬
        .get();

    if (missionSnapshot.docs.isEmpty) {
      return [];
    }

    // 3. 문서 ID를 포함하여 데이터 목록을 반환
    return missionSnapshot.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .toList();
  }

  /// 사용자 ID 목록을 받아 프로필 정보를 Map 형태로 반환하는 내부 헬퍼 함수
  Future<Map<String, Map<String, dynamic>>> _fetchProfilesInChunks(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    final Map<String, Map<String, dynamic>> profiles = {};
    const chunkSize = 30; // Firestore 'whereIn' 쿼리의 최대 개수는 30

    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.sublist(
        i,
        i + chunkSize > userIds.length ? userIds.length : i + chunkSize,
      );
      if (chunk.isEmpty) continue;

      final profileSnapshot = await _firestore
          .collection('profiles')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final profileDoc in profileSnapshot.docs) {
        profiles[profileDoc.id] = profileDoc.data();
      }
    }
    return profiles;
  }
}
