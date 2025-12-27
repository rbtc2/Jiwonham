// 체크리스트 항목 수정 다이얼로그
// 지원 준비 체크리스트 항목을 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

class EditChecklistItemDialog {
  static Future<String?> show(BuildContext context, String initialItem) {
    final itemController = TextEditingController(text: initialItem);
    final itemFocusNode = FocusNode();

    return ModernBottomSheet.showCustom<String>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '항목 수정',
        icon: Icons.edit_outlined,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          // 첫 번째 필드에 자동 포커스 및 텍스트 선택
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (itemFocusNode.canRequestFocus) {
              itemFocusNode.requestFocus();
              itemController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: itemController.text.length,
              );
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '항목명',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: itemController,
                focusNode: itemFocusNode,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: '예: 기업 분석, 이력서 준비',
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
                onSubmitted: (_) {
                  if (itemController.text.trim().isNotEmpty) {
                    itemController.dispose();
                    itemFocusNode.dispose();
                    Navigator.pop(context, itemController.text.trim());
                  }
                },
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          if (itemController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('항목명을 입력해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          itemController.dispose();
          itemFocusNode.dispose();

          Navigator.pop(context, itemController.text.trim());
        },
      ),
    );
  }
}


