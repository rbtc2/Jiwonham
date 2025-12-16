// 문항 수정 다이얼로그
// 자기소개서 문항을 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class EditQuestionDialog extends StatefulWidget {
  final String initialQuestion;
  final int initialMaxLength;

  const EditQuestionDialog({
    super.key,
    required this.initialQuestion,
    required this.initialMaxLength,
  });

  @override
  State<EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<EditQuestionDialog> {
  late final TextEditingController _questionController;
  late final TextEditingController _maxLengthController;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.initialQuestion,
    );
    _maxLengthController = TextEditingController(
      text: widget.initialMaxLength.toString(),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _maxLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('문항 수정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.question,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: '예: 지원 동기를 작성해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText:
                    !_isValid && _questionController.text.trim().isEmpty
                    ? '문항을 입력해주세요.'
                    : null,
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _isValid = _questionController.text.trim().isNotEmpty;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              '${AppStrings.maxCharacters} (${AppStrings.characterCount})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxLengthController,
              decoration: InputDecoration(
                hintText: '500',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText:
                    !_isValid && _maxLengthController.text.trim().isEmpty
                    ? '최대 글자 수를 입력해주세요.'
                    : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _isValid = _maxLengthController.text.trim().isNotEmpty;
                });
              },
            ),
          ],
        ),
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
            final questionText = _questionController.text.trim();
            final maxLengthText = _maxLengthController.text.trim();

            if (questionText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('문항을 입력해주세요.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            if (maxLengthText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('최대 글자 수를 입력해주세요.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final maxLength = int.tryParse(maxLengthText);
            if (maxLength == null || maxLength <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('올바른 최대 글자 수를 입력해주세요.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'question': questionText,
              'maxLength': maxLength,
            });
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}



