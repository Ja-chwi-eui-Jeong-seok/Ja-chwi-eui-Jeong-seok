import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.primaryText = '확인',
    this.secondaryText = '취소',
    this.onPrimary,
    this.onSecondary,
    this.destructive = false,
  });

  final String title;
  final String? message;
  final String primaryText; // 예: 삭제, 확인 등
  final String secondaryText; // 예: 취소, 닫기 등
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final bool destructive; // true면 검정배경 흰글씨

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //큰 제목
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              //작은제목
              Text(
                message!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 25),
            //버튼
            Row(
              children: [
                // 취소
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        onSecondary ?? () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      //padding: const EdgeInsets.symmetric(vertical: 1),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      secondaryText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 확인/삭제
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimary ?? () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      //padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: destructive
                          ? Colors.black
                          : Colors.black, // 필요 시 바꿔도 됨
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      primaryText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unintended_html_in_doc_comment
/// Future<bool?>로 바로 쓰기 좋은 헬퍼
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String primaryText = '확인',
  String secondaryText = '취소',
  Future<void> Function()? onPrimary,
  Future<void> Function()? onSecondary,

  bool destructive = false,
  bool barrierDismissible = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => AppConfirmDialog(
      title: title,
      message: message,
      primaryText: primaryText,
      secondaryText: secondaryText,
      destructive: destructive,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
    ),
  );
}
