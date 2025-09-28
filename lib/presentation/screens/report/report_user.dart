// presentation/screens/report_user_page.dart
import 'package:flutter/material.dart';
import 'package:ja_chwi/data/datasources/report_datasource.dart';
import 'package:ja_chwi/data/repositories/report_repository_impl.dart';

class ReportUserPage extends StatefulWidget {
  final String myUid;
  final String targetUid;

  const ReportUserPage({super.key, required this.myUid, required this.targetUid});

  @override
  State<ReportUserPage> createState() => _ReportUserPageState();
}

class _ReportUserPageState extends State<ReportUserPage> {
  final _reasonController = TextEditingController();
  final reportRepository = ReportRepositoryImpl(remoteDataSource: FirebaseReportDataSource());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("신고하기")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: "신고 사유",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_reasonController.text.isEmpty) return;
                await reportRepository.reportUser(
                  userId: widget.myUid,
                  targetId: widget.targetUid,
                  reason: _reasonController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("신고가 완료되었습니다.")));
                Navigator.pop(context);
              },
              child: const Text("신고 제출"),
            ),
          ],
        ),
      ),
    );
  }
}
