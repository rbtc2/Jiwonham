// 앱 정보 다이얼로그
// 앱 버전과 개발자 정보를 표시하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class AppInfoDialog {
  static Future<void> show(BuildContext context) {
    return ModernBottomSheet.showCustom(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.developerInfo,
        icon: Icons.info_outline,
        iconColor: AppColors.info,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앱 버전 정보
          _buildInfoItem(
            context,
            icon: Icons.phone_android,
            label: AppStrings.appVersion,
            value: '1.0.0',
          ),
          const SizedBox(height: 24),
          // 개발자 정보
          _buildInfoItem(
            context,
            icon: Icons.person_outline,
            label: '개발자',
            value: 'REDIPX',
          ),
        ],
      ),
      actions: ModernBottomSheetActions(
        showCancelButton: false,
        confirmText: AppStrings.confirm,
        onConfirm: () => Navigator.pop(context),
        confirmButtonColor: AppColors.primary,
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

