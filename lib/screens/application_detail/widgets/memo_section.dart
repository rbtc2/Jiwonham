// 메모 섹션 위젯
// 공고에 대한 메모를 표시하고 편집할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../widgets/dialogs/memo_edit_dialog.dart';

class MemoSection extends StatelessWidget {
  final Application application;
  final Function(String) onMemoUpdated;

  const MemoSection({
    super.key,
    required this.application,
    required this.onMemoUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.progressMemo,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '공고에 대한 메모',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await MemoEditDialog.show(
                      context,
                      initialMemo: application.memo,
                    );
                    if (result != null && context.mounted) {
                      onMemoUpdated(result);
                    }
                  },
                  child: const Text(AppStrings.editProgressMemo),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.memo != null && application.memo!.isNotEmpty
                    ? application.memo!
                    : AppStrings.noMemo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: application.memo != null &&
                              application.memo!.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





