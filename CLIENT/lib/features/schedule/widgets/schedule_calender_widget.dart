import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

typedef OnMonthYearChanged = void Function(int month, int year);

class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final int currentMonth;
  final int currentYear;
  final List<dynamic> events; // expects items with 'parsedDate' and 'name'
  final ValueChanged<DateTime> onPageChanged;
  final OnMonthYearChanged onMonthYearChanged;

  const ScheduleCalendar({
    Key? key,
    required this.focusedDay,
    required this.currentMonth,
    required this.currentYear,
    required this.events,
    required this.onPageChanged,
    required this.onMonthYearChanged,
  }) : super(key: key);

  List<dynamic> _eventsForDay(DateTime day) {
    return events
        .where((h) {
          final d = h['parsedDate'] as DateTime?;
          return d != null &&
              d.year == day.year &&
              d.month == day.month &&
              d.day == day.day;
        })
        .map((h) => h['name'])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        locale: 'id_ID',
        firstDay: DateTime(currentYear - 5, 1, 1),
        lastDay: DateTime(currentYear + 5, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: _eventsForDay,
        onPageChanged: onPageChanged,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronVisible: false,
          rightChevronVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (context, day) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final prevMonth = DateTime(day.year, day.month - 1);
                    onPageChanged(prevMonth);
                    onMonthYearChanged(prevMonth.month, prevMonth.year);
                  },
                ),
                Row(
                  children: [
                    // Month dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentMonth,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: List.generate(12, (i) {
                            final m = i + 1;
                            final monthName = DateFormat.MMMM(
                              'id_ID',
                            ).format(DateTime(2000, m));
                            return DropdownMenuItem(
                              value: m,
                              child: Text(monthName),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              onMonthYearChanged(val, currentYear);
                              onPageChanged(DateTime(currentYear, val, 1));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Year dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentYear,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: List.generate(11, (i) {
                            final y = DateTime.now().year - 5 + i;
                            return DropdownMenuItem(
                              value: y,
                              child: Text('$y'),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              onMonthYearChanged(currentMonth, val);
                              onPageChanged(DateTime(val, currentMonth, 1));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final nextMonth = DateTime(day.year, day.month + 1);
                    onPageChanged(nextMonth);
                    onMonthYearChanged(nextMonth.month, nextMonth.year);
                  },
                ),
              ],
            );
          },
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${events.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            );
          },
        ),
        calendarStyle: const CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
