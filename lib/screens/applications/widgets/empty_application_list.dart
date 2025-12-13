// 빈 목록 위젯
// 공고 목록이 비어있을 때 표시되는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class EmptyApplicationList extends StatelessWidget {
  final String tabName;
  final bool hasFilters;
  final VoidCallback onResetFilters;

  const EmptyApplicationList({
    super.key,
    required this.tabName,
    required this.hasFilters,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_alt_off : Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? '필터 조건에 맞는 공고가 없습니다'
                : '$tabName 공고가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onResetFilters,
              child: const Text('필터 초기화'),
            ),
          ],
        ],
      ),
    );
  }
}

