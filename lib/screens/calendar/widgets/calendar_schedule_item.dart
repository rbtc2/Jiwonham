// 캘린더 일정 아이템 위젯
// 하단 일정 목록에서 개별 일정을 표시하는 아이템

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/calendar_event_style.dart';
import '../../../widgets/modern_card.dart';

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

    return ModernCard(
      padding: const EdgeInsets.all(16.0),
      onTap: () => onTap(),
      backgroundColor: style.color.withValues(alpha: 0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(style.icon, color: style.color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  eventTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (event['time'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event['time'] as String,
                style: TextStyle(
                  color: style.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

