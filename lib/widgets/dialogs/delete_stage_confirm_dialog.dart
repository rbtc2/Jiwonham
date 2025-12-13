// 일정 삭제 확인 다이얼로그
// 일정 삭제 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class DeleteStageConfirmDialog extends StatelessWidget {
  const DeleteStageConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일정 삭제'),
      content: const Text('이 일정을 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
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


