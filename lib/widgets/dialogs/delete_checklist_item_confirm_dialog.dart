// 체크리스트 항목 삭제 확인 다이얼로그
// 지원 준비 체크리스트 항목 삭제를 확인하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class DeleteChecklistItemConfirmDialog {
  static Future<bool?> show(BuildContext context, String itemText) {
    return ModernBottomSheet.showCustom<bool>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '항목 삭제',
        icon: Icons.delete_outline,
        iconColor: AppColors.error,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다음 항목을 삭제하시겠습니까?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    itemText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.delete,
        confirmButtonColor: AppColors.error,
        onConfirm: () {
          Navigator.pop(context, true);
        },
      ),
    );
  }
}

