// 캘린더 이벤트 칩 위젯
// 주간 캘린더에서 이벤트를 작은 칩 형태로 표시

import 'package:flutter/material.dart';
import '../../../utils/calendar_event_style.dart';

class CalendarEventChip extends StatelessWidget {
  final Map<String, dynamic> event;

  const CalendarEventChip({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final eventType = event['type'] as String? ?? 'interview';
    final style = CalendarEventStyle.getStyle(eventType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 10, color: style.color),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              style.label,
              style: TextStyle(
                color: style.color,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

