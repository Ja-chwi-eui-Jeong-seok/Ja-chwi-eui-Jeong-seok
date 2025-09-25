import 'package:cloud_firestore/cloud_firestore.dart';

/// 오늘의 미션 코드를 계산하는 유틸리티 함수.
///
/// [userCreateDateTimestamp]: 사용자의 가입일.
/// [totalMissions]: 순환할 전체 미션의 개수.
/// [now]: 현재 시간을 나타내는 DateTime. 테스트 시 특정 날짜를 주입하기 위해 사용.
int calculateTodayMissionCode({
  required Timestamp userCreateDateTimestamp,
  required int totalMissions,
  DateTime? now,
}) {
  if (totalMissions <= 0) {
    // 전체 미션 개수가 0 이하일 경우 항상 1을 반환하여 오류를 방지합니다.
    return 1;
  }

  final userCreateDate = userCreateDateTimestamp.toDate();
  // 시/분/초를 무시하고 날짜만 비교하기 위해 재구성합니다.
  final today = now ?? DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  final userCreateDateOnly = DateTime(
    userCreateDate.year,
    userCreateDate.month,
    userCreateDate.day,
  );

  final int daysPassed = todayDateOnly.difference(userCreateDateOnly).inDays;

  // 오늘의 미션 코드를 계산합니다. (가입일 = 1일차)
  // daysPassed는 0부터 시작하므로 +1을 해주고, 전체 미션 개수를 초과하면 순환하도록 합니다.
  return (daysPassed % totalMissions) + 1;
}
