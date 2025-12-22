// 캘린더 날짜 셀 위젯
// 월간 캘린더에서 개별 날짜를 표시하는 셀

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/calendar_event_marker.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final List<Map<String, dynamic>> events;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            if (events.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.take(3).map((event) {
                  EventType type;
                  if (event['type'] == 'deadline') {
                    type = EventType.deadline;
                  } else if (event['type'] == 'announcement') {
                    type = EventType.announcement;
                  } else {
                    type = EventType.interview;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: CalendarEventMarker(type: type),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}





