// Jachwi 관련 API 호출 구현 (예: Firebase, REST API 등)

abstract class JachwiDataSource {
  Future<String> fetchData();
}

class JachwiDataSourceImpl implements JachwiDataSource {
  @override
  Future<String> fetchData() async {
    // TODO: 실제 API 호출 구현
    return 'data from JachwiDataSource';
  }
}
