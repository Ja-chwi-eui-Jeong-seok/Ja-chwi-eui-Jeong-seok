import 'package:cloud_firestore/cloud_firestore.dart';

/// 미션 목록을 TableCalendar 위젯에서 사용할 수 있는 이벤트 맵으로 변환합니다.
///
/// [missions]는 'missioncreatedate' 필드를 포함하는 Map의 리스트여야 합니다.
/// 반환값은 `DateTime`을 키로, 미션 데이터를 값으로 갖는 맵입니다.
Map<DateTime, Map<String, dynamic>> mapMissionsToCalendarEvents(
  List<Map<String, dynamic>> missions,
) {
  final Map<DateTime, Map<String, dynamic>> eventMap = {};
  for (var mission in missions) {
    // Firestore의 Timestamp를 Dart의 DateTime으로 변환합니다.
    final completedAt = (mission['missioncreatedate'] as Timestamp?)?.toDate();
    if (completedAt != null) {
      // 시간 정보를 제외하고 년, 월, 일만 사용하여 UTC 날짜 객체를 생성합니다.
      final date = DateTime.utc(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
      eventMap[date] = mission;
    }
  }
  return eventMap;
}
