// 메모 편집 다이얼로그
// 공고에 대한 메모를 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class MemoEditDialog {
  static Future<String?> show(
    BuildContext context, {
    String? initialMemo,
  }) {
    final controller = TextEditingController(text: initialMemo ?? '');
    final focusNode = FocusNode();

    return ModernBottomSheet.showCustom<String>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.editMemo,
        icon: Icons.note_outlined,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          // 자동 포커스
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (focusNode.canRequestFocus) {
              focusNode.requestFocus();
            }
          });

          return TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            minLines: 12,
            textInputAction: TextInputAction.newline,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: '메모를 입력하세요\n\n지원 과정 중 빠르게 기록하는 메모입니다.',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                height: 1.5,
              ),
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
