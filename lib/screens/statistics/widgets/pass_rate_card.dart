// Phase 9-3: 합격률 카드 위젯
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../painters/line_chart_painter.dart';

class PassRateCard extends StatelessWidget {
  final int total;
  final int passed;
  final int thisMonthTotal;
  final int thisMonthPassed;

  const PassRateCard({
    super.key,
    required this.total,
    required this.passed,
    required this.thisMonthTotal,
    required this.thisMonthPassed,
  });

  @override
  Widget build(BuildContext context) {
    // Phase 2: 실제 데이터 사용
    final overallRate = total > 0
        ? ((passed / total) * 100).toStringAsFixed(1)
        : '0.0';

    final thisMonthRate = thisMonthTotal > 0
        ? ((thisMonthPassed / thisMonthTotal) * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.passRate,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPassRateItem(
                  context,
                  AppStrings.overall,
                  '$overallRate%',
                  '$passed/$total',
                ),
                _buildPassRateItem(
                  context,
                  AppStrings.thisMonth,
                  '$thisMonthRate%',
                  '$thisMonthPassed/$thisMonthTotal',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 합격률 추이 그래프 (간단한 선 그래프)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: LineChartPainter([16.7, 20.0, 18.5, 19.2]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassRateItem(
    BuildContext context,
    String label,
    String rate,
    String count,
  ) {
    // Phase 8: 접근성 개선 - 합격률 항목에 시맨틱 레이블
    return Semantics(
      label: '$label 합격률: $rate, $count',
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            rate,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            count,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

