// 자기소개서 답변 작성/수정 다이얼로그
// 자기소개서 문항에 대한 답변을 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class CoverLetterAnswerDialog {
  static Future<String?> show(
    BuildContext context, {
    required String question,
    required String initialAnswer,
    required int maxLength,
  }) {
    final controller = TextEditingController(text: initialAnswer);
    final focusNode = FocusNode();

    return ModernBottomSheet.showCustom<String>(
      context: context,
      header: ModernBottomSheetHeader(
        title: question,
        icon: Icons.edit_note,
        iconColor: AppColors.success,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          // 자동 포커스
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (focusNode.canRequestFocus) {
              focusNode.requestFocus();
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                minLines: 10,
                maxLength: maxLength,
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
                  counterStyle: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${controller.text.length} / $maxLength ${AppStrings.characterCount}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          controller.dispose();
          focusNode.dispose();
          Navigator.pop(context, controller.text);
        },
      ),
    );
  }
}






