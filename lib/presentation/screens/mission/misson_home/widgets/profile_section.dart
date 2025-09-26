import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/go_to_completed_button.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 캐릭터 이미지 (임시)
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2C),
            shape: BoxShape.circle,
          ),
          // TODO: 실제 캐릭터 이미지로 교체
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('LV 24', style: TextStyle(fontSize: 16)),
              Text(
                '2조이죠',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const GoToCompletedButton(),
      ],
    );
  }
}
