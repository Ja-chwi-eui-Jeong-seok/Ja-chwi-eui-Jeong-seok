// domain/repositories/report_repository.dart
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<void> reportUser({
    required String userId,
    required String targetId,
    required String reason,
  });

  Future<List<ReportEntity>> fetchReportsByMe(String myUid);
}
