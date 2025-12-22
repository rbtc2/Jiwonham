// 월간 캘린더 뷰 위젯
// 월간 캘린더를 표시하는 위젯

import 'package:flutter/material.dart';
import 'calendar_day_cell.dart';
import 'weekday_header.dart';

class MonthlyCalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> events;
  final Function(DateTime) onDateSelected;
  final bool Function(DateTime, DateTime) isSameDay;
  final List<Map<String, dynamic>> Function(DateTime) getEventsForDate;

  const MonthlyCalendarView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.isSameDay,
    required this.getEventsForDate,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday;
    final daysInMonth = lastDay.day;
    final totalDays = firstDayOfWeek - 1 + daysInMonth;
    final weeks = (totalDays / 7).ceil();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 요일 헤더
          const WeekdayHeader(),
          const SizedBox(height: 8),
          // 캘린더 그리드
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: weeks * 7,
              itemBuilder: (context, index) {
                final dayOffset = index - (firstDayOfWeek - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(
                  currentMonth.year,
                  currentMonth.month,
                  dayOffset + 1,
                );
                final isSelected = isSameDay(date, selectedDate);
                final now = DateTime.now();
                final isToday = isSameDay(date, now);
                final dateEvents = getEventsForDate(date);

                return CalendarDayCell(
                  date: date,
                  isSelected: isSelected,
                  isToday: isToday,
                  events: dateEvents,
                  onTap: () => onDateSelected(date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}





