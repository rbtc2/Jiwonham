// 검색어 Chip 위젯
// 검색어를 표시하고 제거할 수 있는 Chip 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class SearchQueryChip extends StatelessWidget {
  final String query;
  final VoidCallback onDeleted;

  const SearchQueryChip({
    super.key,
    required this.query,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: AppColors.surface,
      child: Wrap(
        spacing: 8,
        children: [
          Chip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, size: 16),
                const SizedBox(width: 4),
                Text(query),
              ],
            ),
            onDeleted: onDeleted,
            deleteIcon: const Icon(Icons.close, size: 18),
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}




