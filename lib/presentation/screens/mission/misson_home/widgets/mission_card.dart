import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/custom_tag.dart';

class MissionCard extends StatelessWidget {
  final String title;
  final List<String> tags;
  final bool isCompleted;
  final String? completionDate; // 완료된 경우에만 사용

  const MissionCard({
    super.key,
    required this.title,
    required this.tags,
    this.isCompleted = false,
    this.completionDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: const Color(0xFFF5F5F5),
        color: const Color(0xD3D3D3D3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 미션 제목과 태그
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: tags
                    .map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CustomTag(tag),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          // 상태에 따라 다른 위젯 표시 (미션하기 버튼 or 완료 날짜)
          if (isCompleted)
            Text(
              completionDate ?? '',
              style: const TextStyle(color: Colors.grey),
            )
          else
            ElevatedButton(
              onPressed: () {
                context.push('/mission-create', extra: title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Row(
                children: [
                  Text('미션 인증하기'),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
