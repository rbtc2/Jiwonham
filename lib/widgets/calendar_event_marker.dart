// 캘린더 이벤트 마커 위젯
// 캘린더에 이벤트를 표시하는 마커

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum EventType {
  deadline,      // 마감일
  announcement,  // 발표일
  interview,    // 면접
}

class CalendarEventMarker extends StatelessWidget {
  final EventType type;
  final int count;

  const CalendarEventMarker({
    super.key,
    required this.type,
    this.count = 1,
  });

  Color _getColor() {
    switch (type) {
      case EventType.deadline:
        return AppColors.error;
      case EventType.announcement:
        return AppColors.info;
      case EventType.interview:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 2,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}
