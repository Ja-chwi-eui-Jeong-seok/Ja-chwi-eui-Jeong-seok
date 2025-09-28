// data/repositories/report_repository_impl.dart
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> reportUser({
    required String userId,
    required String targetId,
    required String reason,
  }) async {
    await remoteDataSource.reportUser(userId: userId, targetId: targetId, reason: reason);
  }

  @override
  Future<List<ReportEntity>> fetchReportsByMe(String myUid) async {
    return await remoteDataSource.fetchReportsByMe(myUid);
  }
}
