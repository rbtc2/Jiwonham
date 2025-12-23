// 지원 준비 체크리스트 섹션 위젯
// 지원 준비 체크리스트를 관리하는 섹션

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/preparation_checklist.dart';
import '../../widgets/modern_card.dart';
import 'checklist_item_widget.dart';

class PreparationChecklistSection extends StatelessWidget {
  final List<PreparationChecklist> checklist;
  final VoidCallback onAddItem;
  final Function(int) onEditItem;
  final Function(int) onDeleteItem;
  final Function(int) onToggleCheck;

  const PreparationChecklistSection({
    super.key,
    required this.checklist,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onToggleCheck,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = checklist.where((item) => item.isChecked).length;
    final totalCount = checklist.length;
    final percentage = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                        child: Text(
                          '지원 준비 체크리스트',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 40), // 아이콘 + 간격 고려
                    child: Text(
                      '지원 준비 항목을 관리합니다',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                '항목 추가',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (checklist.isEmpty)
          ModernCard(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '항목을 추가하려면 [+ 항목 추가] 버튼을 누르세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          ...List.generate(checklist.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ChecklistItemWidget(
                item: checklist[index].item,
                isChecked: checklist[index].isChecked,
                onToggle: () => onToggleCheck(index),
                onEdit: () => onEditItem(index),
                onDelete: () => onDeleteItem(index),
              ),
            );
          }),
          const SizedBox(height: 8),
          ModernCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}

