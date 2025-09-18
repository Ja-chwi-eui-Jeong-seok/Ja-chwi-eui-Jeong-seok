import 'package:flutter/material.dart';

class AchieverCard extends StatelessWidget {
  final String name;
  final String time;
  final Color? backgroundColor;

  const AchieverCard({
    super.key,
    required this.name,
    required this.time,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xD3D3D3D3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              // 프로필 사진
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  shape: BoxShape.circle,
                ),
                // TODO: 실제 캐릭터 이미지로 교체
              ),
              const SizedBox(width: 12),
              // 레벨과 닉네임
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LV.1', // 임시 레벨
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
