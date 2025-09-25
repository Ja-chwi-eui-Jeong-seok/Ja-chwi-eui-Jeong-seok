import 'package:ja_chwi/presentation/screens/mission/core/model/mission_model.dart';

abstract class MissionDataSource {
  /// 오늘 날짜로 이미 완료한 미션이 있는지 확인합니다.
  Future<bool> hasCompletedMissionToday(String userId);

  /// 사진 목록을 스토리지에 업로드하고 URL 목록을 반환합니다.
  /// [photos]는 URL(String)과 로컬 파일(XFile)이 섞인 목록일 수 있습니다.
  Future<List<String>> uploadPhotos(String userId, List<dynamic> photos);

  /// 새로운 미션을 생성합니다.
  Future<void> createMission({
    required String userId,
    required Map<String, dynamic> missionData,
  });

  /// 기존 미션을 수정합니다.
  Future<void> updateMission({
    required String userId,
    required Map<String, dynamic> missionData,
  });

  /// 오늘의 미션 데이터를 가져옵니다.
  Future<Mission> fetchTodayMission();

  /// 사용자의 완료된 미션 목록을 가져오는 스트림입니다.
  Stream<List<Map<String, dynamic>>> fetchUserMissions(String userId);
}
