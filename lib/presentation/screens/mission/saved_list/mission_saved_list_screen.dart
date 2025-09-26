import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/calendar_view.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/completed_mission_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:table_calendar/table_calendar.dart';

class MissionSavedListScreen extends ConsumerStatefulWidget {
  const MissionSavedListScreen({super.key});

  @override
  ConsumerState<MissionSavedListScreen> createState() =>
      _MissionSavedListScreenState();
}

class _MissionSavedListScreenState
    extends ConsumerState<MissionSavedListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final userMissionsAsync = ref.watch(userMissionsProvider);
    final daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;

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
                  daysInMonth,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarAndMissionSection(
    List<Map<String, dynamic>> missions,
    int daysInMonth,
  ) {
    final completedMissions = _mapMissionsToCalendarEvents(missions);

    return Column(
      children: [
        CalendarView(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          totalCompletedMissions: missions.length,
          daysInMonth: daysInMonth,
          consecutiveSuccessDays: _calculateConsecutiveDays(
            completedMissions.keys,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
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
                final isSelected = isSameDay(_selectedDay, day);
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
          selectedDay: _selectedDay,
          completedMissions: completedMissions,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Map<DateTime, Map<String, dynamic>> _mapMissionsToCalendarEvents(
    List<Map<String, dynamic>> missions,
  ) {
    final Map<DateTime, Map<String, dynamic>> eventMap = {};
    for (var mission in missions) {
      final completedAt = mission['missioncreatedate']?.toDate();
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

  int _calculateConsecutiveDays(Iterable<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
    int consecutiveDays = 1;
    DateTime lastDate = sortedDates.first;

    // 오늘 날짜가 포함되어 있는지 확인
    final today = DateTime.now();
    if (!isSameDay(lastDate, today) &&
        !isSameDay(lastDate, today.subtract(const Duration(days: 1)))) {
      return 0; // 마지막 성공일이 어제나 오늘이 아니면 연속 성공 아님
    }

    for (int i = 1; i < sortedDates.length; i++) {
      if (lastDate.difference(sortedDates[i]).inDays == 1) {
        consecutiveDays++;
        lastDate = sortedDates[i];
      } else {
        break;
      }
    }
    return consecutiveDays;
  }
}
