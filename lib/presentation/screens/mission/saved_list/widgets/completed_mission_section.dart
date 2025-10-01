import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/selected_day_mission_view.dart';

class CompletedMissionSection extends ConsumerWidget {
  final DateTime? selectedDay;
  final Map<DateTime, Map<String, dynamic>> completedMissions;

  const CompletedMissionSection({
    super.key,
    required this.selectedDay,
    required this.completedMissions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = selectedDay != null
        ? DateTime.utc(selectedDay!.year, selectedDay!.month, selectedDay!.day)
        : null;
    final missionData = selectedDate != null
        ? completedMissions[selectedDate]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: selectedDay != null
              ? '${selectedDay!.month}.${selectedDay!.day} 완료한 미션'
              : '날짜를 선택해주세요',
          action: missionData == null
              ? null
              : IconButton(
                  onPressed: () async {
                    final result = await context.push(
                      '/mission-create',
                      extra: missionData,
                    );
                    // MissionCreateScreen에서 true를 반환하면 (작업 완료) 데이터를 새로고침
                    if (result == true && context.mounted) {
                      ref.invalidate(userMissionsProvider);
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.square_pencil_fill,
                    color: Colors.black54,
                  ),
                  tooltip: '수정하기',
                ),
        ),
        SelectedDayMissionView(
          selectedDay: selectedDay,
          completedMissions: completedMissions,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        height: 48.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (action != null) action,
          ],
        ),
      ),
    );
  }
}
