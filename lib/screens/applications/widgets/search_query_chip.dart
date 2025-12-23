// 검색어 Chip 위젯
// 검색어를 표시하고 제거할 수 있는 Chip 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/modern_card.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ModernCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.search,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDeleted,
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textSecondary,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(32, 32),
              ),
              tooltip: '검색어 제거',
            ),
          ],
        ),
      ),
    );
  }
}







