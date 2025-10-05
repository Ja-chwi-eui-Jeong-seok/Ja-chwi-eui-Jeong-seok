import 'package:flutter/material.dart';

class ProfileFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int step; // 진행 단계
  final int totalSteps;
  final VoidCallback? onStepBack; // ✅ 이전 스텝 콜백 추가

  const ProfileFlowAppBar({
    super.key,
    required this.step,
    this.totalSteps = 3,
    this.onStepBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: false, // 기본 뒤로가기 제거
      leading: step > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () {
                if (onStepBack != null) {
                  onStepBack!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            )
          : null, // ✅ step == 0이면 버튼 안 보임
      flexibleSpace: SafeArea(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: SizedBox(
                height: 6,
                child: LinearProgressIndicator(
                  value: (step + 1) / totalSteps,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
