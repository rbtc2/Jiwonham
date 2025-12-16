// 캘린더 범례 위젯
// 이벤트 타입별 색상과 라벨을 표시하는 범례

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/calendar_event_style.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            context,
            CalendarEventStyle.getStyle('deadline'),
          ),
          const SizedBox(width: 16),
          _buildLegendItem(
            context,
            CalendarEventStyle.getStyle('announcement'),
          ),
          const SizedBox(width: 16),
          _buildLegendItem(
            context,
            CalendarEventStyle.getStyle('interview'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, CalendarEventStyle style) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: style.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          style.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}


