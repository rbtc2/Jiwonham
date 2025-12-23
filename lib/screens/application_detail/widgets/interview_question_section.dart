// 면접 예상 질문 섹션 위젯
// 면접 예상 질문 목록을 표시하고 새 질문을 추가할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/interview_question.dart';
import '../../../widgets/dialogs/interview_question_dialog.dart';
import 'interview_question_item.dart';

class InterviewQuestionSection extends StatelessWidget {
  final Application application;
  final Function(InterviewQuestion) onQuestionAdded;
  final Function(int, InterviewQuestion) onQuestionUpdated;
  final Function(int, InterviewQuestion) onAnswerUpdated;
  final Function(int) onQuestionDeleted;

  const InterviewQuestionSection({
    super.key,
    required this.application,
    required this.onQuestionAdded,
    required this.onQuestionUpdated,
    required this.onAnswerUpdated,
    required this.onQuestionDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
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
                        AppStrings.interviewExpectedQuestions,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.interviewExpectedQuestionsDesc,
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
                  label: const Text(AppStrings.addInterviewPrepQuestion),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (application.interviewQuestions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.noInterviewQuestions,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(application.interviewQuestions.length, (index) {
                final question = application.interviewQuestions[index];
                return InterviewQuestionItem(
                  question: question,
                  onQuestionUpdated: (updatedQuestion) {
                    onQuestionUpdated(index, updatedQuestion);
                  },
                  onAnswerUpdated: (updatedQuestion) {
                    onAnswerUpdated(index, updatedQuestion);
                  },
                  onDeleted: () {
                    onQuestionDeleted(index);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await InterviewQuestionDialog.show(context);
    if (result != null && context.mounted) {
      // ID 생성 (간단한 UUID 대신 타임스탬프 기반)
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final newQuestion = InterviewQuestion(
        id: id,
        question: result['question'] as String,
      );
      onQuestionAdded(newQuestion);
    }
  }
}

