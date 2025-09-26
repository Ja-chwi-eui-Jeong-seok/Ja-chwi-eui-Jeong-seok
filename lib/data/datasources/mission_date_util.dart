/// 오늘의 미션 코드를 계산하는 유틸리티 함수.
///
/// [totalMissions]: 순환할 전체 미션의 개수.
/// [now]: 현재 시간을 나타내는 DateTime. 테스트 시 특정 날짜를 주입하기 위해 사용.

// 모든 사용자에게 동일한 미션을 제공하기 위한 공통 기준 날짜
final DateTime _baseDate = DateTime.utc(2025, 9, 26);

int calculateTodayMissionCode({
  required int totalMissions,
  DateTime? now,
}) {
  if (totalMissions <= 0) {
    // 전체 미션 개수가 0 이하일 경우 항상 1을 반환하여 오류를 방지합니다.
    return 1;
  }

  // 시/분/초를 무시하고 날짜만 비교하기 위해 재구성합니다.
  final today = now ?? DateTime.now();
  final todayDateOnly = DateTime.utc(today.year, today.month, today.day);

  final int daysPassed = todayDateOnly.difference(_baseDate).inDays;

  // daysPassed가 음수일 수 있으므로, 올바른 모듈로 연산을 위해 totalMissions를 더해줍니다.
  // (daysPassed % totalMissions) 결과가 음수일 경우 totalMissions를 더해 양수로 만들고,
  // 다시 모듈로 연산을 수행하여 0 ~ (totalMissions - 1) 범위의 값을 얻습니다.
  // 최종적으로 +1을 하여 1 ~ totalMissions 범위의 미션 코드를 반환합니다.
  return (daysPassed % totalMissions + totalMissions) % totalMissions + 1;
}
