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
      title: null,
      leadingWidth: 100,
      flexibleSpace: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 중앙 ProgressBar
            Center(
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

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (step > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                    onPressed: () {
                      if (onStepBack != null) {
                        onStepBack!(); // ✅ 이전 스텝으로 이동
                      } else {
                        Navigator.pop(context); // fallback
                      }
                    },
                  )
                
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
