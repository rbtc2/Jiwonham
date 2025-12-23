// 상태 변경 다이얼로그
// 공고 상태를 변경할 수 있는 BottomSheet 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application_status.dart';
import '../../widgets/status_chip.dart';
import 'modern_bottom_sheet.dart';

class StatusChangeDialog {
  static Future<ApplicationStatus?> show(
    BuildContext context,
    ApplicationStatus currentStatus,
  ) {
    ApplicationStatus? selectedStatus = currentStatus;

    return ModernBottomSheet.showCustom<ApplicationStatus>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.changeStatus,
        icon: Icons.swap_horiz,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 현재 상태 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '현재 상태',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 4),
                          StatusChip(status: currentStatus),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 상태 선택 라디오 버튼
              RadioGroup<ApplicationStatus>(
                groupValue: selectedStatus,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
                child: Column(
                  children: [
                    _buildStatusOption(
                      context,
                      ApplicationStatus.notApplied,
                      AppStrings.notAppliedStatus,
                      Icons.pending_outlined,
                    ),
                    _buildStatusOption(
                      context,
                      ApplicationStatus.inProgress,
                      AppStrings.inProgressStatus,
                      Icons.trending_up,
                    ),
                    _buildStatusOption(
                      context,
                      ApplicationStatus.passed,
                      AppStrings.passedStatus,
                      Icons.check_circle_outline,
                    ),
                    _buildStatusOption(
                      context,
                      ApplicationStatus.rejected,
                      AppStrings.rejectedStatus,
                      Icons.cancel_outlined,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        cancelText: AppStrings.cancel,
        confirmText: '변경하기',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          if (selectedStatus != null) {
            Navigator.pop(context, selectedStatus);
          }
        },
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildStatusOption(
    BuildContext context,
    ApplicationStatus status,
    String label,
    IconData icon,
  ) {
    return RadioListTile<ApplicationStatus>(
      value: status,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          StatusChip(status: status),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

