// 다중 삭제 확인 다이얼로그
// 여러 공고를 한 번에 삭제하기 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class MultiDeleteConfirmDialog extends StatelessWidget {
  final int count;

  const MultiDeleteConfirmDialog({
    super.key,
    required this.count,
  });

  static Future<bool?> show(BuildContext context, int count) {
    return showDialog<bool>(
      context: context,
      builder: (context) => MultiDeleteConfirmDialog(count: count),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text(AppStrings.deleteConfirm)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택한 $count개의 공고를 삭제하시겠습니까?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '이 작업은 되돌릴 수 없습니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}

