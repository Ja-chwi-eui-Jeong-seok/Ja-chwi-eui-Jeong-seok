import 'package:ja_chwi/data/datasources/add_mission_datasource.dart';
import 'package:ja_chwi/domain/entities/add_mission_entity.dart';
import 'package:ja_chwi/domain/repositories/add_mission_repository.dart';

class AddMissionRepositoryImpl implements AddMissionRepository {
  final AddMissionDataSource dataSource;

  AddMissionRepositoryImpl(this.dataSource);

  @override
  Stream<List<AddMissionEntity>> getMissions() => dataSource.getMissions();

  @override
  Future<void> addMission(String tag, String title) =>
      dataSource.addMission(tag, title);

  @override
  Future<void> updateMission(String docId, String tag, String title) =>
      dataSource.updateMission(docId, tag, title);

  @override
  Future<void> deleteMission(String docId) =>
      dataSource.deleteMission(docId);
}
