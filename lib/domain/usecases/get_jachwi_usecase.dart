import '../entities/jachwi.dart';
import '../repositories/jachwi_repository.dart';

// 앱의 주요 동작(유즈케이스) 구현 (비즈니스 로직)

class GetJachwiUseCase {
  final JachwiRepository repository;

  GetJachwiUseCase(this.repository);

  Future<Jachwi> execute() {
    return repository.getJachwi();
  }
}
