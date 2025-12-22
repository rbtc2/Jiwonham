// 문항 삭제 확인 다이얼로그
// 문항 삭제 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class DeleteQuestionConfirmDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String questionText,
  }) {
    return ModernBottomSheet.showCustom<bool>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '문항 삭제',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.error,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정말로 이 문항을 삭제하시겠습니까?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Text(
              '"$questionText"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 작업은 되돌릴 수 없습니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
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
