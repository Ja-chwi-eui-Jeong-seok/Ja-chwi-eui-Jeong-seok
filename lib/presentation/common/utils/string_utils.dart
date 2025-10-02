/// 문자열 관련 공용 유틸 함수 모음
class StringUtils {
  /// [text] 가 [cutoff] 글자보다 길면 잘라내고 '...'을 붙여준다.
  static String truncateWithEllipsis(int cutoff, String text) {
    if (text.isEmpty) return text;
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }
}
