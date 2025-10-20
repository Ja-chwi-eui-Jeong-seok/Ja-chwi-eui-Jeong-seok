import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/calendar_view.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/completed_mission_section.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/profile_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:table_calendar/table_calendar.dart';

class MissionSavedListScreen extends ConsumerWidget {
  const MissionSavedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMissionsAsync = ref.watch(userMissionsProvider);
    // mission_providers.dart에 정의된 provider를 사용합니다.
    final selectedDate = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: CommonAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0.0,
        actions: [
          RefreshIconButton(
            onPressed: () => ref.invalidate(userMissionsProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileSection(showButton: false),
              const SizedBox(height: 16),
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
                  selectedDate,
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
    DateTime selectedDate,
  ) {
    final completedMissions = _mapMissionsToCalendarEvents(missions);
    final totalCompletedMissionsForMonth =
        _calculateTotalCompletedMissionsForMonth(missions, selectedDate);
    final daysInMonth = _getDaysInMonth(selectedDate);

    return Column(
      children: [
        CalendarView(
          focusedDay: selectedDate,
          selectedDay: selectedDate,
          totalCompletedMissions: totalCompletedMissionsForMonth,
          daysInMonth: daysInMonth,
          onDaySelected: (selected, focused) {
            // 날짜 선택 시 selectedMonthProvider 상태 업데이트
            ref.read(selectedMonthProvider.notifier).state = selected;
          },
          onPageChanged: (focused) {
            // 페이지(월) 변경 시 selectedMonthProvider 상태 업데이트
            ref.read(selectedMonthProvider.notifier).state = focused;
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
                final isSelected = isSameDay(selectedDate, day);
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
          selectedDay: selectedDate,
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
}
