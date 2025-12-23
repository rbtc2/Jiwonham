// 빈 목록 위젯
// 공고 목록이 비어있을 때 표시되는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/modern_card.dart';

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
    final icon = hasFilters ? Icons.filter_alt_off : Icons.description_outlined;
    final iconColor = hasFilters ? AppColors.warning : AppColors.textSecondary;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ModernCard(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                hasFilters
                    ? '필터 조건에 맞는 공고가 없습니다'
                    : '$tabName 공고가 없습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              if (hasFilters) ...[
                const SizedBox(height: 8),
                Text(
                  '필터를 초기화하여 모든 공고를 확인하세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    '필터 초기화',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}







