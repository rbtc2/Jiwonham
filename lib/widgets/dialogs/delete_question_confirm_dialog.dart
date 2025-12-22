// 문항 삭제 확인 다이얼로그
// 문항 삭제 전 확인을 받는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class DeleteQuestionConfirmDialog extends StatelessWidget {
  final String questionText;

  const DeleteQuestionConfirmDialog({
    super.key,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('문항 삭제'),
      content: Text(
        '정말로 이 문항을 삭제하시겠습니까?\n\n"$questionText"',
      ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}







