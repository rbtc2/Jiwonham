// 캘린더 일정 목록 위젯
// 하단에 선택된 날짜의 일정 목록을 표시

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import 'calendar_schedule_item.dart';

class CalendarScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final String Function(Map<String, dynamic>) getEventTitle;
  final Future<void> Function(Map<String, dynamic>) onEventTap;

  const CalendarScheduleList({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.getEventTitle,
    required this.onEventTap,
  });

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = _getDayOfWeek(selectedDate);

    return Container(
      constraints: const BoxConstraints(
        minHeight: 250,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatDate(selectedDate)} ($dayOfWeek)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.noSchedule,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return CalendarScheduleItem(
                        event: event,
                        eventTitle: getEventTitle(event),
                        onTap: () => onEventTap(event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

