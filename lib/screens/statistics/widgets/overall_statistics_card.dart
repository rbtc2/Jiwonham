// Phase 9-3: 전체 현황 카드 위젯
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../painters/pie_chart_painter.dart';

class OverallStatisticsCard extends StatelessWidget {
  final bool isLoading;
  final int total;
  final int notApplied;
  final int inProgress;
  final int passed;
  final int rejected;

  const OverallStatisticsCard({
    super.key,
    required this.isLoading,
    required this.total,
    required this.notApplied,
    required this.inProgress,
    required this.passed,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    // Phase 4: 로딩 상태 처리
    if (isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.overallStatus,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Phase 8: 접근성 개선 - 로딩 상태 시맨틱 레이블
              Semantics(
                label: '데이터를 불러오는 중입니다',
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Phase 2: 실제 데이터 사용
    final data = [
      {
        'label': AppStrings.notApplied,
        'value': notApplied,
        'color': AppColors.textSecondary,
      },
      {
        'label': AppStrings.inProgress,
        'value': inProgress,
        'color': AppColors.warning,
      },
      {
        'label': AppStrings.passed,
        'value': passed,
        'color': AppColors.success,
      },
      {
        'label': AppStrings.rejected,
        'value': rejected,
        'color': AppColors.error,
      },
    ];

    // Phase 4: 빈 상태 처리
    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.overallStatus,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Phase 8: 접근성 개선 - 빈 상태 메시지에 시맨틱 레이블
              Semantics(
                label: '데이터가 없습니다',
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '데이터가 없습니다',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.overallStatus,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Phase 8: 원형 차트 (접근성 개선 - 시맨틱 레이블 추가)
                Semantics(
                  label:
                      '전체 현황 원형 차트. ${data.map((item) => '${item['label']}: ${item['value']}건').join(', ')}',
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(painter: PieChartPainter(data)),
                  ),
                ),
                const SizedBox(width: 16),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            // Phase 8: 접근성 개선 - 통계 값에 시맨틱 레이블
                            Semantics(
                              label: '${item['label']}: ${item['value']}건',
                              child: Text(
                                '${item['value']}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '전체 지원: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$total건',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

