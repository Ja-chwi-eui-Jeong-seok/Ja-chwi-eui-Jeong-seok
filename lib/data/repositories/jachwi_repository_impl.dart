import '../../domain/entities/jachwi.dart';
import '../../domain/repositories/jachwi_repository.dart';
import '../datasources/jachwi_datasource.dart';

// 도메인 레이어에서 정의한 인터페이스 구현체 (데이터 조작)

class JachwiRepositoryImpl implements JachwiRepository {
  final JachwiDataSource dataSource;

  JachwiRepositoryImpl(this.dataSource);

  @override
  Future<Jachwi> getJachwi() async {
    // TODO: 데이터 변환, 캐싱 등 로직 추가
    final rawData = await dataSource.fetchData();
    // 예시: rawData를 Jachwi 객체로 매핑 필요
    return Jachwi(id: 1, name: rawData);
  }
}
