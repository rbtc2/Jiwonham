// 전형 일정 아이템 위젯
// 다음 전형 일정을 표시하는 아이템 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/date_utils.dart';

class StageItemWidget extends StatelessWidget {
  final String stageType;
  final DateTime stageDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StageItemWidget({
    super.key,
    required this.stageType,
    required this.stageDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stageType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(stageDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 20),
              tooltip: AppStrings.editStage,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              tooltip: AppStrings.deleteStage,
            ),
          ],
        ),
      ),
    );
  }
}






