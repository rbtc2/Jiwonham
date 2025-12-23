// 다음 전형 일정 섹션 위젯
// 다음 전형 일정을 관리하는 섹션

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/modern_card.dart';
import 'stage_item_widget.dart';

class NextStagesSection extends StatelessWidget {
  final List<Map<String, dynamic>> stages;
  final VoidCallback onAddStage;
  final Function(int) onEditStage;
  final Function(int) onDeleteStage;

  const NextStagesSection({
    super.key,
    required this.stages,
    required this.onAddStage,
    required this.onEditStage,
    required this.onDeleteStage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Icons.event,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.nextStage,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onAddStage,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                AppStrings.addStage,
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
        if (stages.isEmpty)
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
                    '일정을 추가하려면 [+ 일정 추가] 버튼을 누르세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(stages.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StageItemWidget(
                stageType: stages[index]['type'] as String,
                stageDate: stages[index]['date'] as DateTime,
                onEdit: () => onEditStage(index),
                onDelete: () => onDeleteStage(index),
              ),
            );
          }),
      ],
    );
  }
}








