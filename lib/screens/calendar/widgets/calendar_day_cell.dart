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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSelected ? 32 : null,
              height: isSelected ? 32 : null,
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: isSelected ? 15 : 14,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
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






