// 체크리스트 항목 위젯
// 지원 준비 체크리스트 항목을 표시하는 아이템 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/modern_card.dart';

class ChecklistItemWidget extends StatelessWidget {
  final String item;
  final bool isChecked;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChecklistItemWidget({
    super.key,
    required this.item,
    required this.isChecked,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primary,
            tooltip: AppStrings.edit,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            tooltip: AppStrings.delete,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}


