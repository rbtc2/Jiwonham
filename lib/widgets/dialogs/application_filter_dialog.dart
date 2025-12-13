// 공고 필터 다이얼로그
// 공고 목록에서 상태 및 마감일 필터를 설정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../models/application_status.dart';

class ApplicationFilterDialog extends StatefulWidget {
  final ApplicationStatus? initialStatusFilter;
  final String? initialDeadlineFilter;

  const ApplicationFilterDialog({
    super.key,
    this.initialStatusFilter,
    this.initialDeadlineFilter,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    ApplicationStatus? initialStatusFilter,
    String? initialDeadlineFilter,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ApplicationFilterDialog(
        initialStatusFilter: initialStatusFilter,
        initialDeadlineFilter: initialDeadlineFilter,
      ),
    );
  }

  @override
  State<ApplicationFilterDialog> createState() =>
      _ApplicationFilterDialogState();
}

class _ApplicationFilterDialogState extends State<ApplicationFilterDialog> {
  late ApplicationStatus? _selectedStatus;
  late String? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatusFilter;
    _selectedDeadline = widget.initialDeadlineFilter;
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        widget.initialStatusFilter != null ||
        widget.initialDeadlineFilter != null;

    return AlertDialog(
      title: const Text(AppStrings.filter),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상태',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            RadioGroup<ApplicationStatus?>(
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
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
            const SizedBox(height: 16),
            Text(
              '마감일',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String?>(
              groupValue: _selectedDeadline,
              onChanged: (value) {
                setState(() {
                  _selectedDeadline = value;
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
        ),
      ),
      actions: [
        // 필터 초기화 버튼 (필터가 적용되어 있을 때만 활성화)
        if (hasActiveFilters)
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedDeadline = null;
              });
            },
            child: const Text(AppStrings.resetFilter),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                'status': _selectedStatus,
                'deadline': _selectedDeadline,
              },
            );
          },
          child: const Text(AppStrings.applyFilter),
        ),
      ],
    );
  }

  String _getStatusText(ApplicationStatus status) {
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

