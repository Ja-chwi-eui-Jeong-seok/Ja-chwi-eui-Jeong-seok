import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_achiever.dart';

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

/// 오늘의 미션 달성자 목록을 제공하는 Provider
final achieversProvider = Provider<List<MissionAchiever>>((ref) {
  // 현재는 목업 데이터를 반환하지만, 나중에는 여기서 API 호출이나
  // 데이터베이스 조회를 통해 실제 데이터를 가져올 수 있습니다.
  return _mockAllAchievers;
});
