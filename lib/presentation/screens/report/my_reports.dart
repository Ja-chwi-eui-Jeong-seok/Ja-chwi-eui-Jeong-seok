import 'package:flutter/material.dart';
import 'package:ja_chwi/data/datasources/report_datasource.dart';
import 'package:ja_chwi/data/repositories/report_repository_impl.dart';
import 'package:ja_chwi/domain/entities/report_entity.dart';

class MyReportsPage extends StatefulWidget {
  final String myUid;
  const MyReportsPage({super.key, required this.myUid});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  late Future<List<ReportEntity>> _myReports;
  final reportRepository = ReportRepositoryImpl(remoteDataSource: FirebaseReportDataSource());

  @override
  void initState() {
    super.initState();
    _myReports = reportRepository.fetchReportsByMe(widget.myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내가 신고한 내역"),
        automaticallyImplyLeading: true, // 기본값 true
        ),
      body: FutureBuilder<List<ReportEntity>>(
        future: _myReports,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("신고한 내역이 없습니다."));

          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text("대상: ${report.targetId}"),
                subtitle: Text(report.reason),
                trailing: Text("${report.createdAt.year}-${report.createdAt.month}-${report.createdAt.day}"),
              );
            },
          );
        },
      ),
    );
  }
}
