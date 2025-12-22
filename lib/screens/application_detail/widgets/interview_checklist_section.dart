// 체크리스트 섹션 위젯
// 면접 준비용 체크리스트를 표시하고 관리하는 섹션

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/dialogs/add_checklist_item_dialog.dart';
import '../application_detail_view_model.dart';
import 'checklist_item.dart';

class InterviewChecklistSection extends StatelessWidget {
  final ApplicationDetailViewModel viewModel;

  const InterviewChecklistSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interviewChecklist,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () async {
                await AddChecklistItemDialog.show(
                  context,
                  onSave: (item) async {
                    final success = await viewModel.addChecklistItem(item);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('체크리스트 항목이 추가되었습니다.'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            viewModel.errorMessage ?? '추가에 실패했습니다.',
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.addChecklistItem),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.application.interviewChecklist.isEmpty)
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
                    AppStrings.noChecklistItems,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            viewModel.application.interviewChecklist.length,
            (index) {
              final item = viewModel.application.interviewChecklist[index];
              return ChecklistItem(
                item: item,
                index: index,
                viewModel: viewModel,
              );
            },
          ),
      ],
    );
  }
}

