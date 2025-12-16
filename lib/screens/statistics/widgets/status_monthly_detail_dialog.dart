// Phase 9-5: 상태별 월별 상세 정보 다이얼로그
import 'package:flutter/material.dart';
import '../../../models/application_status.dart';
import '../utils/statistics_helpers.dart';

/// 상태별 월별 상세 정보 다이얼로그 표시
void showStatusMonthlyDetailDialog(
  BuildContext context,
  String monthKey,
  ApplicationStatus status,
  int count,
  Map<String, Map<ApplicationStatus, int>>? monthlyDataByStatus,
) {
  // Phase 5: 해당 월의 전체 상태별 데이터 가져오기
  final statusData = monthlyDataByStatus?[monthKey];
  final totalCount =
      statusData?.values.fold(0, (sum, count) => sum + count) ?? 0;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$monthKey - ${getStatusText(status)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 5: 선택한 상태의 건수
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getStatusText(status),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Text(
                    '$count건',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ),
            // Phase 5: 전체 건수 및 비율
            if (totalCount > 0) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '전체 대비:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${((count / totalCount) * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

