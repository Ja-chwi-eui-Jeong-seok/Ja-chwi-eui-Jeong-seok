import '../entities/jachwi.dart';

// 추상화된 저장소 인터페이스 정의

abstract class JachwiRepository {
  Future<Jachwi> getJachwi();
}
