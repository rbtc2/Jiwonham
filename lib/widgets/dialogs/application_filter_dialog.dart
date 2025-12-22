// 공고 필터 다이얼로그
// 공고 목록에서 상태 및 마감일 필터를 설정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application_status.dart';
import 'modern_bottom_sheet.dart';

class ApplicationFilterDialog {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    ApplicationStatus? initialStatusFilter,
    String? initialDeadlineFilter,
  }) {
    ApplicationStatus? selectedStatus = initialStatusFilter;
    String? selectedDeadline = initialDeadlineFilter;

    return ModernBottomSheet.showCustom<Map<String, dynamic>>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.filter,
        icon: Icons.filter_list,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '상태',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<ApplicationStatus?>(
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                child: Column(
                  children: [
                    ...ApplicationStatus.values.map((status) {
                      return RadioListTile<ApplicationStatus>(
                        title: Text(_getStatusText(status)),
                        value: status,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    RadioListTile<ApplicationStatus?>(
                      title: const Text('전체'),
                      value: null,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '마감일',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<String?>(
                groupValue: selectedDeadline,
                onChanged: (value) {
                  setState(() {
                    selectedDeadline = value;
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<String?>(
                      title: const Text('전체'),
                      value: null,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String?>(
                      title: const Text(AppStrings.deadlineWithin7Days),
                      value: AppStrings.deadlineWithin7Days,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String?>(
                      title: const Text(AppStrings.deadlineWithin3Days),
                      value: AppStrings.deadlineWithin3Days,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String?>(
                      title: const Text(AppStrings.deadlinePassed),
                      value: AppStrings.deadlinePassed,
                      contentPadding: EdgeInsets.zero,
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
        confirmText: AppStrings.applyFilter,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(
            context,
            {
              'status': selectedStatus,
              'deadline': selectedDeadline,
            },
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  static String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppStrings.notApplied;
      case ApplicationStatus.inProgress:
        return AppStrings.inProgress;
      case ApplicationStatus.passed:
        return AppStrings.passed;
      case ApplicationStatus.rejected:
        return AppStrings.rejected;
      default:
        return AppStrings.all;
    }
  }
}
