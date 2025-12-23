// 일정 아이템 위젯
// 오늘의 일정 목록에서 개별 일정을 표시하는 아이템 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ScheduleItemWidget extends StatelessWidget {
  final IconData icon;
  final String type;
  final String company;
  final String? timeOrDday;
  final Color color;
  final VoidCallback? onTap;

  const ScheduleItemWidget({
    super.key,
    required this.icon,
    required this.type,
    required this.company,
    this.timeOrDday,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                company,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (timeOrDday != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeOrDday!,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

