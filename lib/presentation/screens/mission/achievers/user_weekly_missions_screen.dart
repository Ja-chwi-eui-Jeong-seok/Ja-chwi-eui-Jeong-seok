import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/widgets/completed_mission_card.dart';
import 'package:table_calendar/table_calendar.dart';

/// 특정 유저의 주간 미션 목록을 가져오는 Provider
final userWeeklyMissionsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String userId, DateTime weekDate})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(missionRepositoryProvider);
      return repository.fetchUserMissionsForWeek(
        userId: params.userId,
        dateForWeek: params.weekDate,
      );
    });

class UserWeeklyMissionsScreen extends ConsumerStatefulWidget {
  final MissionAchiever achiever;
  final DateTime weekDate;

  const UserWeeklyMissionsScreen({
    super.key,
    required this.achiever,
    required this.weekDate,
  });

  @override
  ConsumerState<UserWeeklyMissionsScreen> createState() =>
      _UserWeeklyMissionsScreenState();
}

class _UserWeeklyMissionsScreenState
    extends ConsumerState<UserWeeklyMissionsScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.weekDate;
    _selectedDay = widget.weekDate;
  }

  @override
  void didUpdateWidget(covariant UserWeeklyMissionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 부모 위젯(MissionAchieversScreen)에서 주차가 변경되어 weekDate가 바뀌면
    // focusedDay와 selectedDay를 새로운 주차의 날짜로 업데이트합니다.
    if (widget.weekDate != oldWidget.weekDate) {
      setState(() {
        _focusedDay = widget.weekDate;
        _selectedDay = widget.weekDate;
      });
    }
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

  Widget _buildAchieverProfile(MissionAchiever achiever) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: ClipOval(
            child: Image(
              image:
                  (achiever.imageFullUrl.startsWith('http')
                          ? NetworkImage(achiever.imageFullUrl)
                          : AssetImage(achiever.imageFullUrl))
                      as ImageProvider,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 40),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achiever.level,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achiever.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '이번 주 ${achiever.weekCount}회 달성',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(
      userWeeklyMissionsProvider((
        userId: widget.achiever.userId,
        weekDate: widget.weekDate,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${widget.achiever.name}님의 주간 미션',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAchieverProfile(widget.achiever),
              const SizedBox(height: 16),
              missionsAsync.when(
                data: (missions) {
                  final completedMissions = _mapMissionsToCalendarEvents(
                    missions,
                  );
                  final startOfWeek = widget.weekDate.subtract(
                    Duration(days: widget.weekDate.weekday - 1),
                  );
                  final endOfWeek = startOfWeek.add(const Duration(days: 6));

                  final selectedMission = _selectedDay != null
                      ? completedMissions[DateTime.utc(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                        )]
                      : null;

                  return Column(
                    children: [
                      TableCalendar(
                        locale: 'ko_KR',
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        daysOfWeekVisible: false,
                        calendarFormat: CalendarFormat.week,
                        focusedDay: _focusedDay,
                        firstDay: startOfWeek,
                        lastDay: endOfWeek,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        eventLoader: (day) {
                          final date = DateTime.utc(
                            day.year,
                            day.month,
                            day.day,
                          );
                          return completedMissions[date] != null
                              ? [completedMissions[date]]
                              : [];
                        },
                        calendarBuilders: CalendarBuilders(
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.red,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (selectedMission != null)
                        CompletedMissionCard(
                          missionData: selectedMission,
                          isReadOnly: true,
                        )
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('선택한 날짜에 완료한 미션이 없습니다.'),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('미션 목록을 불러오는 데 실패했습니다: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
