// D-day 배지 위젯
// 마감일까지 남은 일수를 표시하는 배지

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DDayBadge extends StatelessWidget {
  final DateTime deadline;
  final bool isUrgent;

  const DDayBadge({
    super.key,
    required this.deadline,
    this.isUrgent = false,
  });

  int _calculateDaysLeft() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    final difference = deadlineDate.difference(today).inDays;
    return difference;
  }

  Color _getBadgeColor(int daysLeft) {
    if (daysLeft < 0) {
      return AppColors.error;
    } else if (daysLeft <= 3) {
      return AppColors.error;
    } else if (daysLeft <= 7) {
      return AppColors.warning;
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _calculateDaysLeft();
    final color = _getBadgeColor(daysLeft);

    String displayText;
    if (daysLeft < 0) {
      displayText = '마감됨';
    } else if (daysLeft == 0) {
      displayText = 'D-Day';
    } else {
      displayText = 'D-$daysLeft';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
