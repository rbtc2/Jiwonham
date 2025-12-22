// 자기소개서 문항 아이템 위젯
// 문항과 답변을 표시하고 편집할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/dialogs/cover_letter_answer_dialog.dart';

class QuestionItem extends StatelessWidget {
  final String question;
  final String answer;
  final int maxLength;
  final int currentLength;
  final bool hasAnswer;
  final Function(String) onAnswerUpdated;

  const QuestionItem({
    super.key,
    required this.question,
    required this.answer,
    required this.maxLength,
    required this.currentLength,
    required this.hasAnswer,
    required this.onAnswerUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAnswerDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAnswerDialog(context),
                  child: Text(
                    hasAnswer ? AppStrings.editAnswer : AppStrings.writeAnswer,
                  ),
                ),
              ],
            ),
            if (hasAnswer) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentLength / $maxLength ${AppStrings.characterCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAnswerDialog(BuildContext context) async {
    final result = await CoverLetterAnswerDialog.show(
      context,
      question: question,
      initialAnswer: answer,
      maxLength: maxLength,
    );
    if (result != null && context.mounted) {
      onAnswerUpdated(result);
    }
  }
}




