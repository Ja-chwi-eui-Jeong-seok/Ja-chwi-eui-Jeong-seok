import 'package:ja_chwi/domain/entities/add_mission_entity.dart';

abstract class AddMissionRepository {
  Stream<List<AddMissionEntity>> getMissions();
  Future<void> addMission(String tag, String title);
  Future<void> updateMission(String docId, String tag, String title);
  Future<void> deleteMission(String docId);
}
