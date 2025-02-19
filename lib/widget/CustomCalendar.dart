import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Map<DateTime, List<dynamic>> Function() getTaskEvents;
  final bool isDarkMode;

  const CustomCalendar({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.getTaskEvents,
    required this.isDarkMode, // Added to track the theme mode
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) =>
          getTaskEvents()[DateTime(day.year, day.month, day.day)] ?? [],
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        defaultTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ), // White (Dark Mode), Black (Light Mode)
        weekendTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ), // White (Dark Mode), Black (Light Mode)
        outsideTextStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade500,
        ), // Dark grey (Dark Mode), Light grey (Light Mode)
        disabledTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.grey.shade500,
        ), // White (Dark Mode), Grey (Light Mode)
        selectedDecoration:
            BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
        markersAlignment: Alignment.bottomCenter,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.red),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          final isOutside = date.month != focusedDay.month;
          return Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isOutside
                    ? (isDarkMode ? Colors.white : Colors.grey.shade500)
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          );
        },
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
