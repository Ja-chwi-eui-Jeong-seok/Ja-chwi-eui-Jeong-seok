import 'package:flutter/material.dart';

class AchieverCard extends StatelessWidget {
  final int rank;
  final String name;
  final String level;

  const AchieverCard({
    super.key,
    required this.rank,
    required this.name,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 등수 표시
        SizedBox(
          width: 32,
          child: Text(
            '$rank',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 8),
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
            Text(
              level,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: 상세보기 페이지로 이동하는 로직 구현
          },
          child: const Row(
            children: [
              Text(
                '상세보기',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 13,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
