import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/triple_arrow_icon.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
      decoration: BoxDecoration(
        // color: const Color(0xFFF5F5F5),
        color: const Color(0xD3D3D3D3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 미션 제목과 태그
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
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
          ),

          const SizedBox(width: 24),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                elevation: 0,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '미션하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  TripleArrowIcon(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
