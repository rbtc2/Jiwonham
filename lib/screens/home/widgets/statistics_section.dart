// 통계 섹션 위젯
// 오늘의 통계를 표시하는 섹션 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import 'stat_card.dart';

class StatisticsSection extends StatelessWidget {
  final int totalApplications;
  final int inProgressCount;
  final int passedCount;

  const StatisticsSection({
    super.key,
    required this.totalApplications,
    required this.inProgressCount,
    required this.passedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.todayStatistics,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: AppStrings.totalApplications,
                value: totalApplications.toString(),
                color: AppColors.primary,
                icon: Icons.description_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: AppStrings.inProgress,
                value: inProgressCount.toString(),
                color: AppColors.warning,
                icon: Icons.hourglass_empty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: AppStrings.passed,
                value: passedCount.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

