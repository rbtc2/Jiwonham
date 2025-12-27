// 주간 캘린더 뷰 위젯
// 주간 캘린더를 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'calendar_event_chip.dart';
import 'weekday_header.dart';

class WeeklyCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> events;
  final Function(DateTime) onDateSelected;
  final bool Function(DateTime, DateTime) isSameDay;
  final List<Map<String, dynamic>> Function(DateTime) getEventsForDate;

  const WeeklyCalendarView({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.isSameDay,
    required this.getEventsForDate,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday % 7),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const WeekdayHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: weekDays.map((date) {
                final isSelected = isSameDay(date, selectedDate);
                final now = DateTime.now();
                final isToday = isSameDay(date, now);
                final dateEvents = getEventsForDate(date);

                return Expanded(
                  child: InkWell(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (dateEvents.isNotEmpty)
                            ...dateEvents.map((event) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: CalendarEventChip(event: event),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}










