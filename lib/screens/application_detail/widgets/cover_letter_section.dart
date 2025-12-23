// 자기소개서 섹션 위젯
// 자기소개서 문항과 답변을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/cover_letter_question.dart';
import '../../../widgets/dialogs/add_question_dialog.dart';
import 'question_item.dart';

class CoverLetterSection extends StatelessWidget {
  final Application application;
  final Function(int, String) onAnswerUpdated;
  final Function(CoverLetterQuestion) onQuestionAdded;

  const CoverLetterSection({
    super.key,
    required this.application,
    required this.onAnswerUpdated,
    required this.onQuestionAdded,
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
                        AppStrings.coverLetterAnswers,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '자기소개서 문항과 답변을 관리합니다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addQuestion),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (application.coverLetterQuestions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        AppStrings.noCoverLetterQuestions,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.editQuestionToAdd,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(application.coverLetterQuestions.length, (
                index,
              ) {
                final question = application.coverLetterQuestions[index];
                final hasAnswer = question.hasAnswer;
                return Column(
                  children: [
                    QuestionItem(
                      question: question.question,
                      answer: question.answer ?? '',
                      maxLength: question.maxLength,
                      currentLength: question.answerLength,
                      hasAnswer: hasAnswer,
                      onAnswerUpdated: (newAnswer) {
                        onAnswerUpdated(index, newAnswer);
                      },
                    ),
                    if (index < application.coverLetterQuestions.length - 1)
                      const Divider(height: 16),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await AddQuestionDialog.show(context);
    if (result != null && context.mounted) {
      final newQuestion = CoverLetterQuestion(
        question: result['question'] as String,
        maxLength: result['maxLength'] as int,
      );
      onQuestionAdded(newQuestion);
    }
  }
}







