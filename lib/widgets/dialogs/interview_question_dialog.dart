// 면접 예상 질문 추가/수정 다이얼로그
// 면접 예상 질문을 추가하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/interview_question.dart';
import 'modern_bottom_sheet.dart';

class InterviewQuestionDialog {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    InterviewQuestion? question,
  }) {
    final isEdit = question != null;
    final questionController = TextEditingController(
      text: question?.question ?? '',
    );
    final questionFocusNode = FocusNode();
    bool isValid = question?.question.isNotEmpty ?? false;

    return ModernBottomSheet.showCustom<Map<String, dynamic>>(
      context: context,
      header: ModernBottomSheetHeader(
        title: isEdit
            ? AppStrings.editInterviewPrepQuestion
            : AppStrings.addInterviewPrepQuestion,
        icon: Icons.help_outline,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          // 첫 번째 필드에 자동 포커스
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (questionFocusNode.canRequestFocus) {
              questionFocusNode.requestFocus();
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: questionController,
                focusNode: questionFocusNode,
                maxLines: null,
                minLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: '예: 지원 동기를 말씀해주세요.',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorText: !isValid && questionController.text.trim().isEmpty
                      ? '질문을 입력해주세요.'
                      : null,
                  contentPadding: const EdgeInsets.all(20),
                ),
                onChanged: (value) {
                  setState(() {
                    isValid = questionController.text.trim().isNotEmpty;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          final questionText = questionController.text.trim();

          if (questionText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('질문을 입력해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          questionController.dispose();
          questionFocusNode.dispose();

          Navigator.pop(context, {
            'question': questionText,
          });
        },
      ),
    );
  }
}

