// 면접 예상 질문 답변 작성/수정 다이얼로그
// 면접 예상 질문에 대한 답변을 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class InterviewAnswerDialog {
  static Future<String?> show(
    BuildContext context, {
    required String question,
    required String initialAnswer,
  }) {
    final controller = TextEditingController(text: initialAnswer);
    final focusNode = FocusNode();
    final isEdit = initialAnswer.isNotEmpty;

    return ModernBottomSheet.showCustom<String>(
      context: context,
      header: ModernBottomSheetHeader(
        title: isEdit
            ? AppStrings.editInterviewAnswer
            : AppStrings.writeInterviewAnswer,
        icon: Icons.edit_note,
        iconColor: AppColors.success,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (focusNode.canRequestFocus) {
              focusNode.requestFocus();
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                        question,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.answer,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                minLines: 10,
                textInputAction: TextInputAction.newline,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '답변을 입력하세요',
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
                  contentPadding: const EdgeInsets.all(20),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          final answer = controller.text.trim();
          controller.dispose();
          focusNode.dispose();
          Navigator.pop(context, answer);
        },
      ),
    );
  }
}

