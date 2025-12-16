// 자기소개서 문항 섹션 위젯
// 자기소개서 문항을 관리하는 섹션

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/cover_letter_question.dart';
import 'question_item_widget.dart';

class CoverLetterQuestionsSection extends StatelessWidget {
  final List<CoverLetterQuestion> questions;
  final VoidCallback onAddQuestion;
  final Function(int) onEditQuestion;
  final Function(int) onDeleteQuestion;

  const CoverLetterQuestionsSection({
    super.key,
    required this.questions,
    required this.onAddQuestion,
    required this.onEditQuestion,
    required this.onDeleteQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.coverLetterQuestions,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '문항 구조를 관리합니다. 답변은 공고 상세에서 작성합니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onAddQuestion,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addQuestion),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (questions.isEmpty)
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '문항을 추가하려면 [+ 문항 추가] 버튼을 누르세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(questions.length, (index) {
            return QuestionItemWidget(
              question: questions[index],
              index: index,
              onEdit: () => onEditQuestion(index),
              onDelete: () => onDeleteQuestion(index),
            );
          }),
      ],
    );
  }
}



