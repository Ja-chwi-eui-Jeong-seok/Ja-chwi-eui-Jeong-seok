import 'package:ja_chwi/domain/repositories/mission_repository.dart';

class FetchTodayMissionAchieversUseCase {
  final MissionRepository repository;

  FetchTodayMissionAchieversUseCase(this.repository);

  Future<List<Map<String, dynamic>>> execute() {
    return repository.fetchTodayMissionAchievers();
  }
}
