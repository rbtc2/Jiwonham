// 면접 예상 질문 아이템 위젯
// 개별 면접 예상 질문을 표시하고 편집/삭제할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/interview_question.dart';
import '../../../widgets/dialogs/interview_answer_dialog.dart';
import '../../../widgets/dialogs/interview_question_dialog.dart';

class InterviewQuestionItem extends StatelessWidget {
  final InterviewQuestion question;
  final Function(InterviewQuestion) onQuestionUpdated;
  final Function(InterviewQuestion) onAnswerUpdated;
  final VoidCallback onDeleted;

  const InterviewQuestionItem({
    super.key,
    required this.question,
    required this.onQuestionUpdated,
    required this.onAnswerUpdated,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswer = question.hasAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q. ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Expanded(
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasAnswer) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A. ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
                Expanded(
                  child: Text(
                    question.answer!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAnswerDialog(context),
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text(AppStrings.writeInterviewAnswer),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasAnswer)
                TextButton(
                  onPressed: () => _showAnswerDialog(context),
                  child: const Text(AppStrings.editInterviewAnswer),
                ),
              TextButton(
                onPressed: () => _showEditQuestionDialog(context),
                child: const Text(AppStrings.editInterviewPrepQuestion),
              ),
              TextButton(
                onPressed: onDeleted,
                child: Text(
                  AppStrings.deleteInterviewPrepQuestion,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAnswerDialog(BuildContext context) async {
    final result = await InterviewAnswerDialog.show(
      context,
      question: question.question,
      initialAnswer: question.answer ?? '',
    );
    if (result != null && context.mounted) {
      final updatedQuestion = question.copyWith(answer: result);
      onAnswerUpdated(updatedQuestion);
    }
  }

  Future<void> _showEditQuestionDialog(BuildContext context) async {
    final result = await InterviewQuestionDialog.show(
      context,
      question: question,
    );
    if (result != null && context.mounted) {
      final updatedQuestion = question.copyWith(
        question: result['question'] as String,
      );
      onQuestionUpdated(updatedQuestion);
    }
  }
}

