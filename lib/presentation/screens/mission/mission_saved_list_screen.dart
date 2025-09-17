import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/calendar_view.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/selected_day_mission_view.dart';
import 'package:table_calendar/table_calendar.dart';

class MissionSavedListScreen extends StatefulWidget {
  const MissionSavedListScreen({super.key});

  @override
  State<MissionSavedListScreen> createState() => _MissionSavedListScreenState();
}

class _MissionSavedListScreenState extends State<MissionSavedListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 임시 데이터
  final int _totalCompletedMissions = 10;
  final int _consecutiveSuccessDays = 4;

  // 날짜별 완료된 미션 데이터 (임시)
  final Map<DateTime, Map<String, dynamic>> _completedMissions = {
    DateTime.utc(DateTime.now().year, 9, 12): {
      'title': '삼시세끼 다 먹기',
      'tags': ['건강', '요리'],
    },
    DateTime.utc(DateTime.now().year, 9, 10): {
      'title': '아침 9시 기상',
      'tags': ['생활패턴'],
    },
  };

  List<dynamic> _getEventsForDay(DateTime day) {
    // table_calendar는 local time으로 날짜를 전달하므로, UTC로 변환하여 Map의 키와 비교
    final date = DateTime.utc(day.year, day.month, day.day);
    if (_completedMissions.containsKey(date)) {
      return [_completedMissions[date]!]; // 점을 표시하기 위해 리스트에 아이템을 추가
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [RefreshIconButton(onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarView(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                totalCompletedMissions: _totalCompletedMissions,
                daysInMonth: daysInMonth,
                consecutiveSuccessDays: _consecutiveSuccessDays,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                eventLoader: _getEventsForDay,
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
                      // 선택된 날짜에 이벤트 마커가 있으면 색상을 흰색으로 변경하여 가시성 확보
                      final isSelected = isSameDay(_selectedDay, day);
                      return Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.check,
                          color: isSelected ? Colors.white : Colors.red,
                          size: 16,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                _selectedDay != null
                    ? '${_selectedDay!.month}.${_selectedDay!.day} 완료 미션'
                    : '날짜를 선택해주세요',
              ),
              SelectedDayMissionView(
                selectedDay: _selectedDay,
                completedMissions: _completedMissions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // 섹션 제목을 만드는 헬퍼 메소드
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
