// 공고 삭제 확인 다이얼로그
// 공고 삭제 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class DeleteApplicationConfirmDialog {
  static Future<bool?> show(BuildContext context) {
    return ModernBottomSheet.showConfirm(
      context: context,
      title: AppStrings.deleteConfirm,
      message: AppStrings.deleteConfirmMessage,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      confirmText: AppStrings.delete,
      confirmButtonColor: AppColors.error,
    );
  }
}
