import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class FetchReportsByMe {
  final ReportRepository repository;

  FetchReportsByMe(this.repository);

  Future<List<ReportEntity>> call(String myUid) async {
    return await repository.fetchReportsByMe(myUid);
  }
}
