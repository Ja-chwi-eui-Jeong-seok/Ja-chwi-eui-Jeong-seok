import 'package:flutter/material.dart';

class MissionInfoBox extends StatelessWidget {
  final String missionTitle;

  const MissionInfoBox({super.key, required this.missionTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xD3D3D3D3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: '오늘의 미션 : ',
              style: TextStyle(color: Colors.grey[700]),
            ),
            TextSpan(text: missionTitle),
          ],
        ),
      ),
    );
  }
}
