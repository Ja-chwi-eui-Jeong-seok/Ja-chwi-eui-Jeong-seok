import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<dynamic> Function(DateTime)? eventLoader;

  const CalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        focusedDay: focusedDay,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(color: Colors.blue),
          holidayTextStyle: const TextStyle(color: Colors.red),
          holidayDecoration: const BoxDecoration(shape: BoxShape.rectangle),
        ),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        holidayPredicate: (day) => day.weekday == DateTime.sunday,
        onDaySelected: onDaySelected,
        eventLoader: eventLoader,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              // Positioned 위젯을 사용하여 마커의 위치를 조정합니다.
              return Positioned(
                right: 5,
                top: 5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black, // 마커 색상
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
