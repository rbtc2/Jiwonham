// 체크리스트 아이템 위젯
// 개별 체크리스트 항목을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/interview_checklist.dart';
import '../../../widgets/dialogs/edit_checklist_item_dialog.dart';
import '../application_detail_view_model.dart';

class ChecklistItem extends StatelessWidget {
  final InterviewChecklist item;
  final int index;
  final ApplicationDetailViewModel viewModel;

  const ChecklistItem({
    super.key,
    required this.item,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (value) async {
              final success = await viewModel.toggleChecklistItem(
                index,
                value ?? false,
              );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.errorMessage ?? '업데이트에 실패했습니다.',
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: Text(
              item.item,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? AppColors.textSecondary : null,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () async {
              await EditChecklistItemDialog.show(
                context,
                initialItem: item.item,
                onSave: (updatedItem) async {
                  final success = await viewModel.updateChecklistItem(
                    index,
                    updatedItem,
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('체크리스트 항목이 수정되었습니다.'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.errorMessage ?? '수정에 실패했습니다.',
                        ),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () async {
              final success = await viewModel.deleteChecklistItem(index);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('체크리스트 항목이 삭제되었습니다.'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.errorMessage ?? '삭제에 실패했습니다.',
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

