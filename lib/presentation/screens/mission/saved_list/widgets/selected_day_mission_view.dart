import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/custom_tag.dart';

class SelectedDayMissionView extends StatelessWidget {
  final DateTime? selectedDay;
  final Map<DateTime, Map<String, dynamic>> completedMissions;

  const SelectedDayMissionView({
    super.key,
    required this.selectedDay,
    required this.completedMissions,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const SizedBox.shrink();
    }

    final selectedDate = DateTime.utc(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );
    final missionData = completedMissions[selectedDate];

    if (missionData != null) {
      final String title = missionData['title'] as String;
      final List<String> tags = List<String>.from(
        missionData['tags'] as List? ?? [],
      );
      final List<String> photos =
          (missionData['photos'] as List?)?.cast<String>() ?? [];
      final bool isPublic = missionData['isPublic'] as bool? ?? false;
      final String description = missionData['description'] as String? ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 미션 제목
                Padding(
                  padding: const EdgeInsets.only(
                    right: 70.0,
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 태그
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: tags.map((tag) => CustomTag(tag)).toList(),
                  ),
                const SizedBox(height: 20),

                // 인증 사진
                if (photos.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(photos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 설명
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 0,
              child: Row(
                children: [
                  Icon(
                    isPublic
                        ? CupertinoIcons.lock_fill
                        : CupertinoIcons.lock_open_fill,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPublic ? '공개' : '비공개',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 200,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '이 날짜에 완료한 미션이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }
}
