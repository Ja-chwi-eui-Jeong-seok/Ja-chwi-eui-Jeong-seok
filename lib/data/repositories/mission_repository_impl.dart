import 'package:ja_chwi/data/datasources/mission_datasource.dart';
import 'package:ja_chwi/domain/repositories/mission_repository.dart';

import '../../presentation/screens/mission/core/model/mission_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  final MissionDataSource dataSource;

  MissionRepositoryImpl(this.dataSource);

  @override
  Future<bool> hasCompletedMissionToday(String userId) {
    return dataSource.hasCompletedMissionToday(userId);
  }

  @override
  Future<List<String>> uploadPhotos(String userId, List<dynamic> photos) {
    return dataSource.uploadPhotos(userId, photos);
  }

  @override
  Future<void> createMission({
    required String userId,
    required Map<String, dynamic> missionData,
  }) {
    return dataSource.createMission(userId: userId, missionData: missionData);
  }

  @override
  Future<void> updateMission({
    required String userId,
    required String docId,
    required Map<String, dynamic> missionData,
  }) {
    return dataSource.updateMission(
      userId: userId,
      docId: docId,
      missionData: missionData,
    );
  }

  @override
  Future<Mission> fetchTodayMission(
    String userId, {
    DateTime? debugNow,
  }) {
    return dataSource.fetchTodayMission(userId, debugNow: debugNow);
  }

  @override
  Stream<List<Map<String, dynamic>>> fetchUserMissions(String userId) {
    return dataSource.fetchUserMissions(userId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTodayMissionAchievers() =>
      dataSource.fetchTodayMissionAchievers();
}
