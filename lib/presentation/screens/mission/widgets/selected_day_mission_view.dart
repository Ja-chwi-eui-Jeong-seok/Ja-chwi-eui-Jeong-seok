import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/mission_card.dart';

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
      return MissionCard(
        title: missionData['title'] as String,
        tags: missionData['tags'] as List<String>,
        isCompleted: true,
        completionDate:
            '${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')} 완료',
      );
    } else {
      return Container(
        height: 105,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '이 날짜에 완료한 미션이 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
  }
}
