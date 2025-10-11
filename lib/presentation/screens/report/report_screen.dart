import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/providers/report_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String targetUserId;
  final String? targetUserName;
  final String? targetContent; // 댓글 내용이나 게시글 내용
  final DateTime? targetCreatedAt; // 신고 대상의 생성 시간

  const ReportScreen({
    super.key,
    required this.targetUserId,
    this.targetUserName,
    this.targetContent,
    this.targetCreatedAt,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final List<String> _reportReasons = [
    '부적절한 언어 사용',
    '과한 욕설 및 비속어 사용',
    '상대를 비하하는 언어 사용',
    '스팸 또는 광고성 게시물',
    '기타 사유',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 신고 사유 제목
            const Text(
              '신고 사유',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 신고 사유 목록
            ..._reportReasons.map((reason) => _buildReasonTile(reason)),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // 사유 선택 시 바로 다음 페이지로 이동
          context.push(
            '/report-detail',
            extra: {
              'targetUserId': widget.targetUserId,
              'targetUserName': widget.targetUserName,
              'targetContent': widget.targetContent,
              'targetCreatedAt': widget.targetCreatedAt,
              'selectedReason': reason,
            },
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
