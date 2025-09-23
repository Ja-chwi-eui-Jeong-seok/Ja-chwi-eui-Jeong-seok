import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_model.dart';

/// Repository

// TODO: 실제 앱에서는 이 데이터를 API 호출 등을 통해 비동기적으로 가져와야 합니다.
// 이 경우, Provider 대신 FutureProvider 또는 StreamProvider를 사용하는 것이 좋습니다.
final List<MissionAchiever> _mockAllAchievers = [
  MissionAchiever(name: '집인데 집가고 싶다님', time: '08:12 완료', level: 'Lv.15'),
  MissionAchiever(name: '아니 아님', time: '09:12 완료', level: 'Lv.10'),
  MissionAchiever(name: '뿌뿌로', time: '10:12 완료', level: 'Lv.5'),
  MissionAchiever(name: '네번째 달성자', time: '11:00 완료', level: 'Lv.4'),
  MissionAchiever(name: '다섯번째 달성자', time: '12:00 완료', level: 'Lv.3'),
  MissionAchiever(name: '여섯번째 달성자', time: '13:00 완료', level: 'Lv.2'),
];

class MissionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 오늘의 미션 데이터를 가져오는 함수
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
    // Mission 모델의 fromFirestore 팩토리 생성자에서 'missiontag'를 처리하도록 수정했으므로,
    // 해당 생성자를 다시 사용합니다. 이렇게 하면 코드 관리가 더 용이해집니다.
    return Mission.fromFirestore(missionQuery.docs.first);
    // --- 개발용 임시 코드 끝 ---
  }
}

/// Providers

/// 오늘의 미션 달성자 목록을 제공하는 Provider
final achieversProvider = Provider<List<MissionAchiever>>((ref) {
  // 현재는 목업 데이터를 반환하지만, 나중에는 여기서 API 호출이나
  // 데이터베이스 조회를 통해 실제 데이터를 가져올 수 있습니다.
  return _mockAllAchievers;
});

/// MissionRepository를 제공하는 Provider
final missionRepositoryProvider = Provider((ref) => MissionRepository());

/// 오늘의 미션 데이터를 비동기적으로 가져오는 FutureProvider
final todayMissionProvider = FutureProvider<Mission>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return repository.fetchTodayMission();
});
