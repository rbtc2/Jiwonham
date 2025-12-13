// 다음 전형 일정 섹션 위젯
// 다음 전형 일정을 관리하는 섹션

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
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
                Icon(Icons.event, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.nextStage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onAddStage,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addStage),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (stages.isEmpty)
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '일정을 추가하려면 [+ 일정 추가] 버튼을 누르세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(stages.length, (index) {
            return StageItemWidget(
              stageType: stages[index]['type'] as String,
              stageDate: stages[index]['date'] as DateTime,
              onEdit: () => onEditStage(index),
              onDelete: () => onDeleteStage(index),
            );
          }),
      ],
    );
  }
}


