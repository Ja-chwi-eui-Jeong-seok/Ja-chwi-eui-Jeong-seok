import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/providers/report_provider.dart';
import 'package:ja_chwi/presentation/widgets/report_complete_dialog.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String targetUserId;
  final String? targetUserName;
  final String? targetContent;
  final DateTime? targetCreatedAt;
  final String selectedReason;

  const ReportDetailScreen({
    super.key,
    required this.targetUserId,
    this.targetUserName,
    this.targetContent,
    this.targetCreatedAt,
    required this.selectedReason,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final TextEditingController _detailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_detailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 세부사유를 입력해주세요.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reason =
          '${widget.selectedReason}: ${_detailController.text.trim()}';

      await ref.read(reportUserActionProvider)(
        userId: currentUser.uid,
        targetId: widget.targetUserId,
        reason: reason,
      );

      if (mounted) {
        // 신고 완료 후 알림 다이얼로그 표시
        await showReportCompleteDialog(
          context,
          onConfirm: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            context.pop(); // 신고 세부사유 페이지 닫기
            context.pop(); // 신고 사유 선택 페이지 닫기
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // 키보드 포커스 해제 (키보드 내리기)
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent, // 빈 공간도 터치 인식되게
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 선택된 사유와 대상 정보 표시
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.selectedReason,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (widget.targetCreatedAt != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'MM.dd HH:mm',
                                  ).format(widget.targetCreatedAt!.toLocal()),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 세부사유 입력
                    const Text(
                      '신고 세부사유에 대하여 얘기해주세요.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _detailController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: '신고 사유를 자세히 설명해주세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Spacer 제거 (하단 버튼은 Column 밖의 고정 패딩에 위치)
                  ],
                ),
              ),
            ),

            // 작성 완료 버튼 (하단 고정)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Text(
                          '작성 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
