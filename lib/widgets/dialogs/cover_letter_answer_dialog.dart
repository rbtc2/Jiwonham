// 자기소개서 답변 작성/수정 다이얼로그
// 자기소개서 문항에 대한 답변을 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class CoverLetterAnswerDialog extends StatefulWidget {
  final String question;
  final String initialAnswer;
  final int maxLength;

  const CoverLetterAnswerDialog({
    super.key,
    required this.question,
    required this.initialAnswer,
    required this.maxLength,
  });

  static Future<String?> show(
    BuildContext context, {
    required String question,
    required String initialAnswer,
    required int maxLength,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => CoverLetterAnswerDialog(
        question: question,
        initialAnswer: initialAnswer,
        maxLength: maxLength,
      ),
    );
  }

  @override
  State<CoverLetterAnswerDialog> createState() =>
      _CoverLetterAnswerDialogState();
}

class _CoverLetterAnswerDialogState extends State<CoverLetterAnswerDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(widget.question),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                maxLines: 10,
                maxLength: widget.maxLength,
                decoration: InputDecoration(
                  hintText: '답변을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${_controller.text.length} / ${widget.maxLength} ${AppStrings.characterCount}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
              Navigator.pop(context, _controller.text);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}

