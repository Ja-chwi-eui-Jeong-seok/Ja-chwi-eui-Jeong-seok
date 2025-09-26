import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/mission_datasource_impl.dart';
import 'package:ja_chwi/data/datasources/image_picker_datasource_impl.dart';
import 'package:ja_chwi/data/repositories/mission_repository_impl.dart';
import 'package:ja_chwi/data/repositories/image_picker_repository_impl.dart';
import 'package:ja_chwi/domain/repositories/mission_repository.dart';
import 'package:ja_chwi/domain/usecases/pick_images_usecase.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_model.dart';
import 'package:image_picker/image_picker.dart';

/// Repository

// TODO: 실제 앱에서는 이 데이터를 API 호출 등을 통해 비동기적으로 가져와야 합니다.
// 이 경우, Provider 대신 FutureProvider 또는 StreamProvider를 사용하는 것이 좋습니다.
final List<MissionAchiever> _mockAllAchievers = [
  MissionAchiever(name: '집인데 집가고 싶다님', time: '08:12 완료', level: 'Lv.15'),
  MissionAchiever(name: '아니 아님', time: '09:12 완료', level: 'Lv.10'),
  MissionAchiever(name: '뿌뿌로', time: '10:12 완료', level: 'Lv.5'),
  MissionAchiever(name: '네번째 달성자', time: '11:00 완료', level: 'Lv.4'),
  MissionAchiever(name: '다섯번째 달성자', time: '12:00 완료', level: 'Lv.3'),
  MissionAchiever(name: '여섯번째 달성자', time: '13:00 완료', level: 'Lv.5'),
  MissionAchiever(name: '일곱번째 달성자', time: '14:00 완료', level: 'Lv.2'),
  MissionAchiever(name: '여덟번째 달성자', time: '09:00 완료', level: 'Lv.1'),
  MissionAchiever(name: '아홉번째 달성자', time: '11:30 완료', level: 'Lv.2'),
  MissionAchiever(name: '열번째 달성자', time: '15:00 완료', level: 'Lv.1'),
  MissionAchiever(name: '열한번째 달성자', time: '16:00 완료', level: 'Lv.3'),
  MissionAchiever(name: '열두번째 달성자', time: '17:00 완료', level: 'Lv.4'),
  MissionAchiever(name: '열세번째 달성자', time: '20:00 완료', level: 'Lv.4'),
  MissionAchiever(name: '열네번째 달성자', time: '12:00 완료', level: 'Lv.5'),
  MissionAchiever(name: '열다섯번째 달성자', time: '21:00 완료', level: 'Lv.6'),
  MissionAchiever(name: '열여섯번째 달성자', time: '22:00 완료', level: 'Lv.10'),
  MissionAchiever(name: '열일곱번째 달성자', time: '23:00 완료', level: 'Lv.5'),
];

/// Providers

/// 오늘의 미션 달성자 목록을 제공하는 Provider
final achieversProvider = Provider<List<MissionAchiever>>((ref) {
  return _mockAllAchievers;
});

/// MissionRepository를 제공하는 Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final dataSource = MissionDataSourceImpl(firestore, storage);
  return MissionRepositoryImpl(dataSource);
});

/// PickImagesUseCase를 제공하는 Provider
final pickImagesUseCaseProvider = Provider<PickImagesUseCase>((ref) {
  final picker = ImagePicker();
  final dataSource = ImagePickerDataSourceImpl(picker);
  final repository = ImagePickerRepositoryImpl(dataSource);
  return PickImagesUseCase(repository);
});

/// 오늘의 미션 데이터를 비동기적으로 가져오는 FutureProvider
final todayMissionProvider = FutureProvider<Mission>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // 로그인한 사용자가 없으면 미션을 가져올 수 없으므로 예외를 발생시킵니다.
    // UI에서는 이 예외를 처리하여 로그인 화면으로 유도하거나 에러 메시지를 보여줄 수 있습니다.
    throw Exception('로그인한 사용자가 없습니다.');
  }
  final repository = ref.watch(missionRepositoryProvider);

  // --- 테스트 코드 적용 위치 ---
  // 아래 코드의 주석을 해제하여 특정 날짜의 미션을 테스트할 수 있습니다.
  // return repository.fetchTodayMission(user.uid, debugNow: DateTime.now().add(const Duration(days: 1))); // 내일 미션 테스트
  return repository.fetchTodayMission(user.uid); // 원래 코드
});

/// 사용자의 미션 목록을 제공하는 StreamProvider
final userMissionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // 로그인하지 않은 사용자는 빈 목록을 반환
    return Stream.value([]);
  }
  return repository.fetchUserMissions(user.uid);
});
