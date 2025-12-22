// 면접 일정 섹션 위젯
// 면접 일정 정보를 표시하고 관리하는 섹션

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/dialogs/interview_schedule_dialog.dart';
import '../application_detail_view_model.dart';

class InterviewScheduleSection extends StatelessWidget {
  final ApplicationDetailViewModel viewModel;

  const InterviewScheduleSection({
    super.key,
    required this.viewModel,
  });

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interviewSchedule,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () async {
                await InterviewScheduleDialog.show(
                  context,
                  initialDate: viewModel.application.interviewSchedule?.date,
                  initialLocation:
                      viewModel.application.interviewSchedule?.location,
                  onSave: (date, location) async {
                    final success = await viewModel.updateInterviewSchedule(
                      date: date,
                      location: location,
                    );
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('면접 일정이 저장되었습니다.'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            viewModel.errorMessage ?? '저장에 실패했습니다.',
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              child: Text(
                viewModel.application.interviewSchedule?.hasSchedule == true
                    ? '수정'
                    : '설정',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.application.interviewSchedule?.hasSchedule != true)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.noInterviewSchedule,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.application.interviewSchedule?.date != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(
                          viewModel.application.interviewSchedule!.date!,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (viewModel.application.interviewSchedule?.location != null &&
                    viewModel
                        .application
                        .interviewSchedule!
                        .location!
                        .isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.application.interviewSchedule!.location!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

