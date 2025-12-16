// Phase 9-3: 주요 통계 카드 위젯
import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';

class KeyStatisticsCard extends StatelessWidget {
  final List<Application> filteredApplications;
  final int inProgress;

  const KeyStatisticsCard({
    super.key,
    required this.filteredApplications,
    required this.inProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Phase 6: 실제 데이터 계산
    // 평균 지원 기간 계산 (생성일부터 현재까지의 평균 일수)
    final now = DateTime.now();
    final applicationsWithPeriod = filteredApplications
        .where((app) => app.createdAt.isBefore(now))
        .toList();
    final averagePeriod = applicationsWithPeriod.isEmpty
        ? 0
        : (applicationsWithPeriod
                      .map((app) => now.difference(app.createdAt).inDays)
                      .fold(0, (sum, days) => sum + days) /
                  applicationsWithPeriod.length)
              .round();

    // 가장 많이 지원한 직무 계산
    final positionCounts = <String, int>{};
    for (final app in filteredApplications) {
      if (app.position != null && app.position!.isNotEmpty) {
        final position = app.position!;
        positionCounts[position] = (positionCounts[position] ?? 0) + 1;
      }
    }
    final mostAppliedPosition = positionCounts.isEmpty
        ? '없음'
        : positionCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
    final mostAppliedPositionCount = positionCounts.isEmpty
        ? 0
        : positionCounts[mostAppliedPosition] ?? 0;

    // 진행 중인 공고 수
    final inProgressCount = inProgress;

    // 마감 임박 공고 수 (D-7 이내)
    final urgentCount = filteredApplications
        .where((app) => app.isUrgent)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.keyStatistics,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              context,
              AppStrings.averageApplicationPeriod,
              averagePeriod > 0 ? '$averagePeriod일' : '데이터 없음',
            ),
            const Divider(),
            _buildStatItem(
              context,
              AppStrings.mostAppliedPosition,
              mostAppliedPositionCount > 0
                  ? '$mostAppliedPosition ($mostAppliedPositionCount건)'
                  : '데이터 없음',
            ),
            const Divider(),
            _buildStatItem(
              context,
              AppStrings.inProgressApplications,
              '$inProgressCount건',
            ),
            const Divider(),
            _buildStatItem(
              context,
              AppStrings.urgentApplicationsCount,
              '$urgentCount건',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    // Phase 8: 접근성 개선 - 통계 항목에 시맨틱 레이블
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

