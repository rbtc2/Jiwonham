// 문항 추가 다이얼로그
// 자기소개서 문항을 추가하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class AddQuestionDialog {
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    final questionController = TextEditingController();
    final maxLengthController = TextEditingController(text: '500');
    final questionFocusNode = FocusNode();
    final maxLengthFocusNode = FocusNode();
    bool isValid = true;

    return ModernBottomSheet.showCustom<Map<String, dynamic>>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.addQuestion,
        icon: Icons.add_circle_outline,
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
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => maxLengthFocusNode.requestFocus(),
                decoration: InputDecoration(
                  hintText: '예: 지원 동기를 작성해주세요.',
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
                  errorText:
                      !isValid && questionController.text.trim().isEmpty
                      ? '문항을 입력해주세요.'
                      : null,
                  contentPadding: const EdgeInsets.all(20),
                ),
                onChanged: (value) {
                  setState(() {
                    isValid = questionController.text.trim().isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                '${AppStrings.maxCharacters} (${AppStrings.characterCount})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxLengthController,
                focusNode: maxLengthFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: '500',
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
                  errorText:
                      !isValid && maxLengthController.text.trim().isEmpty
                      ? '최대 글자 수를 입력해주세요.'
                      : null,
                  contentPadding: const EdgeInsets.all(20),
                ),
                onChanged: (value) {
                  setState(() {
                    isValid = maxLengthController.text.trim().isNotEmpty;
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
          final maxLengthText = maxLengthController.text.trim();

          if (questionText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('문항을 입력해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          if (maxLengthText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('최대 글자 수를 입력해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          final maxLength = int.tryParse(maxLengthText);
          if (maxLength == null || maxLength <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('올바른 최대 글자 수를 입력해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          questionController.dispose();
          maxLengthController.dispose();
          questionFocusNode.dispose();
          maxLengthFocusNode.dispose();

          Navigator.pop(context, {
            'question': questionText,
            'maxLength': maxLength,
          });
        },
      ),
    );
  }
}
