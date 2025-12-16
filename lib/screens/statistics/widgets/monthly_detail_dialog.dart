// Phase 9-5: 월별 상세 정보 다이얼로그
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/application_status.dart';
import '../utils/statistics_helpers.dart';

/// 월별 상세 정보 다이얼로그 표시
void showMonthlyDetailDialog(
  BuildContext context,
  String monthKey,
  int totalCount,
  Map<String, Map<ApplicationStatus, int>>? monthlyDataByStatus,
) {
  // Phase 5: 해당 월의 상태별 데이터 가져오기
  final statusData = monthlyDataByStatus?[monthKey];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(monthKey),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 5: 전체 건수
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '전체 지원:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '$totalCount건',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Phase 5: 상태별 상세 정보
            if (statusData != null && statusData.isNotEmpty) ...[
              const Divider(),
              ...statusData.entries.map((entry) {
                final status = entry.key;
                final count = entry.value;
                if (count == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            getStatusText(status),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Text(
                        '$count건',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
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

