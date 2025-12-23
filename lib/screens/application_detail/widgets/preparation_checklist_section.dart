// 지원 준비 체크리스트 섹션 위젯 (상세 페이지용)
// 체크 상태 변경은 가능하지만 편집/삭제는 수정 화면에서만 가능

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/preparation_checklist.dart';

class PreparationChecklistSection extends StatelessWidget {
  final List<PreparationChecklist> checklist;
  final Function(int) onToggleCheck;

  const PreparationChecklistSection({
    super.key,
    required this.checklist,
    required this.onToggleCheck,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = checklist.where((item) => item.isChecked).length;
    final totalCount = checklist.length;
    final percentage = totalCount > 0
        ? (completedCount / totalCount * 100).round()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.checklist,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지원 준비 체크리스트',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '체크 항목을 완료하세요',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (checklist.isEmpty)
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '체크리스트 항목이 없습니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ...List.generate(checklist.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildChecklistItem(
                    context,
                    checklist[index],
                    index,
                  ),
                );
              }),
              const SizedBox(height: 12),
              // 진행률 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 18,
                      color: percentage == 100
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '진행률: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                    ),
                    Text(
                      '$completedCount/$totalCount 완료',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: percentage == 100
                                ? AppColors.success
                                : AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($percentage%)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: percentage == 100
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    PreparationChecklist item,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (_) => onToggleCheck(index),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.item,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.isChecked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

