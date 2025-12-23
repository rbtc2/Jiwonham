// 자기소개서 섹션 위젯
// 자기소개서 문항과 답변을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import 'question_item.dart';

class CoverLetterSection extends StatelessWidget {
  final Application application;
  final Function(int, String) onAnswerUpdated;

  const CoverLetterSection({
    super.key,
    required this.application,
    required this.onAnswerUpdated,
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
                        '문항은 수정 화면에서 관리할 수 있습니다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
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
}







