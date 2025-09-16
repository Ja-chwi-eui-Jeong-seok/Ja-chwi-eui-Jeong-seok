import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_saved_list_screen.dart';

class GoToCompletedButton extends StatelessWidget {
  const GoToCompletedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MissionSavedListScreen(),
          ),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xD3D3D3D3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '완료된 미션 보러가기',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
        ],
      ),
    );
  }
}
