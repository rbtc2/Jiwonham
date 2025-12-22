// 일정 삭제 확인 다이얼로그
// 일정 삭제 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class DeleteStageConfirmDialog {
  static Future<bool?> show(BuildContext context) {
    return ModernBottomSheet.showConfirm(
      context: context,
      title: '일정 삭제',
      message: '이 일정을 삭제하시겠습니까?',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      confirmText: AppStrings.delete,
      confirmButtonColor: AppColors.error,
    );
  }
}
