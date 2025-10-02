// 앱에서 발생하는 예외 정의 및 처리용 커스텀 예외 클래스

class JachwiException implements Exception {
  final String message;
  JachwiException(this.message);

  @override
  String toString() => 'JachwiException: $message';
}
