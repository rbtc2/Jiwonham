// 면접 질문 준비 섹션 위젯
// 면접 질문 목록을 표시하고 관리하는 섹션

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/dialogs/add_interview_question_dialog.dart';
import '../application_detail_view_model.dart';
import 'interview_question_item.dart';

class InterviewQuestionsSection extends StatelessWidget {
  final ApplicationDetailViewModel viewModel;

  const InterviewQuestionsSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interviewQuestionsPrep,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () async {
                await AddInterviewQuestionDialog.show(
                  context,
                  onSave: (question) async {
                    final success = await viewModel.addInterviewQuestion(
                      question,
                    );
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('면접 질문이 추가되었습니다.'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            viewModel.errorMessage ?? '추가에 실패했습니다.',
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.addInterviewPrepQuestion),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.application.interviewQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
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
          ...List.generate(
            viewModel.application.interviewQuestions.length,
            (index) {
              final question = viewModel.application.interviewQuestions[index];
              return InterviewQuestionItem(
                question: question,
                index: index,
                viewModel: viewModel,
              );
            },
          ),
      ],
    );
  }
}

