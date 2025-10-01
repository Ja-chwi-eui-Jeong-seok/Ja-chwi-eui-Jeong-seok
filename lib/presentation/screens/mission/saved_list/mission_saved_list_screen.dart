import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/calendar_view.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/completed_mission_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:table_calendar/table_calendar.dart';

/// `focusedDay` 상태를 관리하는 Provider. 캘린더에서 현재 보여지는 월을 추적합니다.
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// `selectedDay` 상태를 관리하는 Provider. 사용자가 캘린더에서 선택한 날짜를 추적합니다.
final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());

class MissionSavedListScreen extends ConsumerWidget {
  const MissionSavedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMissionsAsync = ref.watch(userMissionsProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      appBar: CommonAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        actions: [
          RefreshIconButton(onPressed: () => ref.refresh(userMissionsProvider)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userMissionsAsync.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (userMissionsAsync.hasError)
                Center(
                  child: Text('데이터를 불러올 수 없습니다: ${userMissionsAsync.error}'),
                )
              else
                _buildCalendarAndMissionSection(
                  userMissionsAsync.value ?? [],
                  ref,
                  focusedDay,
                  selectedDay,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarAndMissionSection(
    List<Map<String, dynamic>> missions,
    WidgetRef ref,
    DateTime focusedDay,
    DateTime? selectedDay,
  ) {
    final completedMissions = _mapMissionsToCalendarEvents(missions);
    final totalCompletedMissionsForMonth =
        _calculateTotalCompletedMissionsForMonth(missions, focusedDay);
    final daysInMonth = _getDaysInMonth(focusedDay);

    return Column(
      children: [
        CalendarView(
          focusedDay: focusedDay,
          selectedDay: selectedDay,
          totalCompletedMissions: totalCompletedMissionsForMonth,
          daysInMonth: daysInMonth,
          consecutiveSuccessDays: _calculateConsecutiveDays(
            completedMissions.keys,
          ),
          onDaySelected: (selected, focused) {
            ref.read(selectedDayProvider.notifier).state = selected;
            ref.read(focusedDayProvider.notifier).state = focused;
          },
          onPageChanged: (focused) {
            ref.read(focusedDayProvider.notifier).state = focused;
          },
          eventLoader: (day) {
            final date = DateTime.utc(day.year, day.month, day.day);
            return completedMissions[date] != null
                ? [completedMissions[date]]
                : [];
          },
          builders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  day.day.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty) {
                final isSelected = isSameDay(selectedDay, day);
                return Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 7,
                    width: 7,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // 선택된 날짜에는 흰색 점, 아닐 경우 빨간 점
                      color: isSelected ? Colors.white : Colors.red,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        CompletedMissionSection(
          selectedDay: selectedDay,
          completedMissions: completedMissions,
        ),
      ],
    );
  }

  Map<DateTime, Map<String, dynamic>> _mapMissionsToCalendarEvents(
    List<Map<String, dynamic>> missions,
  ) {
    final Map<DateTime, Map<String, dynamic>> eventMap = {};
    for (var mission in missions) {
      final completedAt = (mission['missioncreatedate'] as Timestamp?)
          ?.toDate();
      if (completedAt != null) {
        final date = DateTime.utc(
          completedAt.year,
          completedAt.month,
          completedAt.day,
        );

        eventMap[date] = mission;
      }
    }
    return eventMap;
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _calculateTotalCompletedMissionsForMonth(
    List<Map<String, dynamic>> missions,
    DateTime focusedDay,
  ) {
    return missions.where((m) {
      final completedAt = m['missioncreatedate']?.toDate();
      if (completedAt == null) {
        return false;
      }
      return completedAt.year == focusedDay.year &&
          completedAt.month == focusedDay.month;
    }).length;
  }

  int _calculateConsecutiveDays(Iterable<DateTime> dates) {
    if (dates.isEmpty) {
      return 0;
    }

    final completedDatesSet = dates.toSet();
    final today = DateTime.now();
    final todayUtc = DateTime.utc(today.year, today.month, today.day);

    // 시작 날짜를 정합니다. 오늘 미션을 완료했으면 오늘부터, 아니면 어제부터 확인
    DateTime currentDate = completedDatesSet.contains(todayUtc)
        ? todayUtc
        : todayUtc.subtract(const Duration(days: 1));

    // 시작 날짜의 미션이 완료되지 않았다면 연속일은 0
    if (!completedDatesSet.contains(currentDate)) {
      return 0;
    }

    int consecutiveDays = 0;
    // currentDate부터 과거로 하루씩 이동하며 연속된 날짜인지 확인
    while (completedDatesSet.contains(currentDate)) {
      consecutiveDays++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return consecutiveDays;
  }
}
