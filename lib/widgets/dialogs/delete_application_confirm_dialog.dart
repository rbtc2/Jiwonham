// 공고 삭제 확인 다이얼로그
// 공고 삭제 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class DeleteApplicationConfirmDialog extends StatelessWidget {
  const DeleteApplicationConfirmDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const DeleteApplicationConfirmDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.deleteConfirm),
      content: const Text(AppStrings.deleteConfirmMessage),
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

