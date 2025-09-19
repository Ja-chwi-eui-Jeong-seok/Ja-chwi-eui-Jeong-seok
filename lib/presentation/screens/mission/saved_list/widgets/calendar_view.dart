import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<dynamic> Function(DateTime)? eventLoader;
  final CalendarBuilders builders;

  final int totalCompletedMissions;
  final int daysInMonth;
  final int consecutiveSuccessDays;

  const CalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.eventLoader,
    this.builders = const CalendarBuilders(),
    required this.totalCompletedMissions,
    required this.daysInMonth,
    required this.consecutiveSuccessDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            focusedDay: focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            daysOfWeekHeight: 30,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              holidayDecoration: const BoxDecoration(shape: BoxShape.rectangle),
            ),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            holidayPredicate: (day) => day.weekday == DateTime.sunday,
            onDaySelected: onDaySelected,
            eventLoader: eventLoader,
            calendarBuilders: CalendarBuilders(
              selectedBuilder: builders.selectedBuilder,
              todayBuilder: builders.todayBuilder,
              markerBuilder: builders.markerBuilder,
              dowBuilder: (context, day) {
                final text = DateFormat.E('ko_KR').format(day);
                TextStyle? style;
                if (day.weekday == DateTime.sunday) {
                  style = const TextStyle(color: Colors.red);
                } else if (day.weekday == DateTime.saturday) {
                  style = const TextStyle(color: Colors.blue);
                }
                return Center(child: Text(text, style: style));
              },
              defaultBuilder: (context, day, focusedDay) {
                if (day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.blue),
                    ),
                  );
                }
                return null;
              },
              holidayBuilder: (context, day, events) {
                return Center(
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '미션 성공률',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: '$totalCompletedMissions',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '/$daysInMonth',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '연속 성공한 일 수',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: '$consecutiveSuccessDays',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const TextSpan(
                            text: '일',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
