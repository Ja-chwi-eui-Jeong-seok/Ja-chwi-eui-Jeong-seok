import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class ReportUser {
  final ReportRepository repository;

  ReportUser(this.repository);

  Future<void> call({
    required String userId,
    required String targetId,
    required String reason,
  }) async {
    await repository.reportUser(
      userId: userId,
      targetId: targetId,
      reason: reason,
    );
  }
}
