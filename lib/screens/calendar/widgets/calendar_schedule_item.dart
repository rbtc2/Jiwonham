// 캘린더 일정 아이템 위젯
// 하단 일정 목록에서 개별 일정을 표시하는 아이템

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/calendar_event_style.dart';

class CalendarScheduleItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final String eventTitle;
  final Future<void> Function() onTap;

  const CalendarScheduleItem({
    super.key,
    required this.event,
    required this.eventTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eventType = event['type'] as String? ?? 'interview';
    final style = CalendarEventStyle.getStyle(eventType);

    // 면접 타입 정보 표시 개선
    final stageType = event['stageType'] as String?;
    final displayLabel = stageType != null && eventType == 'interview'
        ? '${style.label} ($stageType)'
        : style.label;

    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: style.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(style.icon, color: style.color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (event['time'] != null)
              Text(
                event['time'] as String,
                style: TextStyle(
                  color: style.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

