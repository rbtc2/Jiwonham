// 캘린더 이벤트 카드 위젯
// 일간 캘린더에서 이벤트를 카드 형태로 표시

import 'package:flutter/material.dart';
import '../../../utils/calendar_event_style.dart';

class CalendarEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String eventTitle;
  final Future<void> Function() onTap;

  const CalendarEventCard({
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(style.icon, color: style.color),
        ),
        title: Text(
          eventTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(displayLabel),
        trailing: event['time'] != null
            ? Text(
                event['time'] as String,
                style: TextStyle(
                  color: style.color,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        onTap: () => onTap(),
      ),
    );
  }
}

