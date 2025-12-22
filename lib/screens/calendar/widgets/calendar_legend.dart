// 캘린더 범례 위젯
// 이벤트 타입별 색상과 라벨을 표시하는 범례

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/calendar_event_style.dart';
import '../../../widgets/modern_card.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ModernCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              context,
              CalendarEventStyle.getStyle('deadline'),
            ),
            const SizedBox(width: 20),
            _buildLegendItem(
              context,
              CalendarEventStyle.getStyle('announcement'),
            ),
            const SizedBox(width: 20),
            _buildLegendItem(
              context,
              CalendarEventStyle.getStyle('interview'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, CalendarEventStyle style) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: style.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          style.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}





