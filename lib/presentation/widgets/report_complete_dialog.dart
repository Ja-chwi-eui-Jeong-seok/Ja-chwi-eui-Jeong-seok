import 'package:flutter/material.dart';

class ReportCompleteDialog extends StatelessWidget {
  const ReportCompleteDialog({
    super.key,
    this.onConfirm,
  });

  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 메인 메시지
            const Text(
              '신고가 완료되었습니다!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // 서브 메시지
            const Text(
              '2-3일 내로 조치 완료하겠습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

/// 신고완료 다이얼로그를 표시하는 헬퍼 함수
Future<void> showReportCompleteDialog(
  BuildContext context, {
  VoidCallback? onConfirm,
  bool barrierDismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => ReportCompleteDialog(
      onConfirm: onConfirm,
    ),
  );
}
