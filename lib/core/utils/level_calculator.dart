/// 미션 카운트를 기반으로 사용자 레벨을 계산하고 포맷팅된 문자열을 반환합니다.
///
/// [missionCount]: 사용자가 완료한 총 미션의 수.
///
/// 로직:
/// - 레벨은 `(미션 카운트 / 7)의 몫 + 1` 입니다.
/// - 최대 레벨은 10으로 제한됩니다.
/// - 결과는 "Lv.X" 형태로 반환됩니다.
String calculateLevel(int missionCount) {
  int level = (missionCount / 7).floor() + 1;
  if (level > 10) {
    level = 10; // 최대 레벨 10으로 제한
  }
  return 'Lv.$level';
}
