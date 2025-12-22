// 면접 질문 아이템 위젯
// 개별 면접 질문과 답변을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/interview_question.dart';
import '../../../widgets/dialogs/edit_interview_question_dialog.dart';
import '../../../widgets/dialogs/interview_answer_dialog.dart';
import '../application_detail_view_model.dart';

class InterviewQuestionItem extends StatelessWidget {
  final InterviewQuestion question;
  final int index;
  final ApplicationDetailViewModel viewModel;

  const InterviewQuestionItem({
    super.key,
    required this.question,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () async {
                      await EditInterviewQuestionDialog.show(
                        context,
                        initialQuestion: question.question,
                        onSave: (updatedQuestion) async {
                          final success = await viewModel
                              .updateInterviewQuestion(index, updatedQuestion);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('면접 질문이 수정되었습니다.'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  viewModel.errorMessage ?? '수정에 실패했습니다.',
                                ),
                                backgroundColor: AppColors.error,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () async {
                      final success = await viewModel.deleteInterviewQuestion(
                        index,
                      );
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('면접 질문이 삭제되었습니다.'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              viewModel.errorMessage ?? '삭제에 실패했습니다.',
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
          if (question.hasAnswer) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                await InterviewAnswerDialog.show(
                  context,
                  question: question.question,
                  initialAnswer: question.answer ?? '',
                  onSave: (answer) async {
                    final success = await viewModel.updateInterviewAnswer(
                      index,
                      answer,
                    );
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('면접 답변이 저장되었습니다.'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            viewModel.errorMessage ?? '저장에 실패했습니다.',
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.answer!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.editInterviewAnswer,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                InterviewAnswerDialog.show(
                  context,
                  question: question.question,
                  initialAnswer: question.answer ?? '',
                  onSave: (answer) async {
                    final success = await viewModel.updateInterviewAnswer(
                      index,
                      answer,
                    );
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('면접 답변이 저장되었습니다.'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            viewModel.errorMessage ?? '저장에 실패했습니다.',
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              child: Text(AppStrings.writeInterviewAnswer),
            ),
          ],
        ],
      ),
    );
  }
}

