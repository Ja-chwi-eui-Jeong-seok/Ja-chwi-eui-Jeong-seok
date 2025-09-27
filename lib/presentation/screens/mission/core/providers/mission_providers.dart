import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/mission_datasource_impl.dart';
import 'package:ja_chwi/data/datasources/image_picker_datasource_impl.dart';
import 'package:ja_chwi/data/repositories/mission_repository_impl.dart';
import 'package:ja_chwi/data/repositories/image_picker_repository_impl.dart';
import 'package:ja_chwi/domain/repositories/mission_repository.dart';
import 'package:ja_chwi/domain/usecases/fetch_user_profile_usecase.dart';
import 'package:ja_chwi/domain/usecases/fetch_today_mission_achievers_usecase.dart';
import 'package:ja_chwi/domain/usecases/pick_images_usecase.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/user_profile.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_model.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

/// Repository

/// Providers

/// 오늘의 미션 달성자 목록을 비동기적으로 가져오는 FutureProvider
final achieversProvider = FutureProvider<List<MissionAchiever>>((ref) async {
  final usecase = ref.watch(fetchTodayMissionAchieversUseCaseProvider);
  final achieversData = await usecase.execute();
  return achieversData.map((data) => MissionAchiever.fromMap(data)).toList();
});

/// 현재 사용자의 프로필 정보를 비동기적으로 가져오는 FutureProvider
final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final usecase = ref.watch(fetchUserProfileUseCaseProvider);
  return usecase.execute().map((userProfileData) {
    return UserProfile.fromMap(userProfileData);
  });
});

/// MissionRepository를 제공하는 Provider
final missionRepositoryProvider = StateProvider<MissionRepository>((ref) {
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

/// FetchTodayMissionAchieversUseCase를 제공하는 Provider
final fetchTodayMissionAchieversUseCaseProvider =
    Provider<FetchTodayMissionAchieversUseCase>((ref) {
      return FetchTodayMissionAchieversUseCase(
        ref.watch(missionRepositoryProvider),
      );
    });

/// FetchUserProfileUseCase를 제공하는 Provider
final fetchUserProfileUseCaseProvider = Provider<FetchUserProfileUseCase>((
  ref,
) {
  return FetchUserProfileUseCase(ref.watch(missionRepositoryProvider));
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
