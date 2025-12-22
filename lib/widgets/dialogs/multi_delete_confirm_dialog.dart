// 다중 삭제 확인 다이얼로그
// 여러 공고를 한 번에 삭제하기 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class MultiDeleteConfirmDialog {
  static Future<bool?> show(BuildContext context, int count) {
    return ModernBottomSheet.showCustom<bool>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.deleteConfirm,
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.error,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택한 $count개의 공고를 삭제하시겠습니까?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '이 작업은 되돌릴 수 없습니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
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
        onConfirm: () => Navigator.pop(context, true),
        confirmButtonColor: AppColors.error,
      ),
      isScrollControlled: false,
    );
  }
}
