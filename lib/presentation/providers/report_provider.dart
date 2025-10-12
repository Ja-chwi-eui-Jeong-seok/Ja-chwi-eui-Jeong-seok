import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/data/datasources/report_datasource.dart';
import 'package:ja_chwi/data/repositories/report_repository_impl.dart';
import 'package:ja_chwi/domain/usecases/report_user.dart';
import 'package:ja_chwi/domain/usecases/fetch_reports_by_me.dart';

// Repository provider
final reportRepositoryProvider = Provider<ReportRepositoryImpl>((ref) {
  return ReportRepositoryImpl(remoteDataSource: FirebaseReportDataSource());
});

// Usecase providers
final reportUserProvider = Provider<ReportUser>((ref) {
  return ReportUser(ref.read(reportRepositoryProvider));
});

final fetchReportsByMeProvider = Provider<FetchReportsByMe>((ref) {
  return FetchReportsByMe(ref.read(reportRepositoryProvider));
});

// Action provider for reporting
final reportUserActionProvider = Provider<
  Future<void> Function({
    required String userId,
    required String targetId,
    required String reason,
  })
>((ref) {
  return ({
    required String userId,
    required String targetId,
    required String reason,
  }) async {
    await ref.read(reportUserProvider).call(
      userId: userId,
      targetId: targetId,
      reason: reason,
    );
  };
});

// Fetch reports by me provider
final myReportsProvider = FutureProvider.family<List<dynamic>, String>((ref, myUid) async {
  final reports = await ref.read(fetchReportsByMeProvider).call(myUid);
  return reports;
});
