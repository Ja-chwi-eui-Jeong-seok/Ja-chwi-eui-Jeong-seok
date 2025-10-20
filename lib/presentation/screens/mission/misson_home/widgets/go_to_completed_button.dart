import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/mission_arrow_icon.dart';

class GoToCompletedButton extends StatelessWidget {
  const GoToCompletedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/mission-saved-list'),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.white, // 화이트
              Color(0xFFF8DCBC), // 진한 주황
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 6,
            top: 24,
            bottom: 24,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '완료된 미션 보러가기',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MissionArrowIcon(),
            ],
          ),
        ),
      ),
    );
  }
}
