// 폴더 이름 수정 다이얼로그

import 'package:flutter/material.dart';
import '../../../models/archive_folder.dart';
import '../../../widgets/dialogs/modern_bottom_sheet.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class EditFolderDialog {
  static Future<ArchiveFolder?> show(
    BuildContext context,
    ArchiveFolder folder,
  ) {
    final nameController = TextEditingController(text: folder.name);
    final focusNode = FocusNode();
    final isValidNotifier = ValueNotifier<bool>(false);

    // 자동 포커스 및 텍스트 선택
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
        nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: nameController.text.length,
        );
      }
    });

    return ModernBottomSheet.showCustom<ArchiveFolder>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '폴더 이름 변경',
        icon: Icons.edit_outlined,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return ValueListenableBuilder<bool>(
            valueListenable: isValidNotifier,
            builder: (context, isValid, _) {
              return TextField(
                controller: nameController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: '폴더 이름',
                  hintText: '폴더 이름을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  counterText: '${nameController.text.length}/20',
                  counterStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                autofocus: true,
                maxLength: 20,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  final newName = value.trim();
                  final newIsValid =
                      newName.isNotEmpty && newName != folder.name;
                  if (isValidNotifier.value != newIsValid) {
                    isValidNotifier.value = newIsValid;
                  }
                },
                onSubmitted: (_) {
                  if (isValidNotifier.value) {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty && newName != folder.name) {
                      final updatedFolder = folder.copyWith(
                        name: newName,
                        updatedAt: DateTime.now(),
                      );
                      nameController.dispose();
                      focusNode.dispose();
                      isValidNotifier.dispose();
                      Navigator.pop(context, updatedFolder);
                    }
                  }
                },
              );
            },
          );
        },
      ),
      actions: ModernBottomSheetActions(
        cancelText: AppStrings.cancel,
        confirmText: '변경',
        onCancel: () {
          nameController.dispose();
          focusNode.dispose();
          isValidNotifier.dispose();
          Navigator.pop(context);
        },
        onConfirm: () {
          final newName = nameController.text.trim();
          if (newName.isEmpty || newName == folder.name) {
            return; // 유효하지 않으면 아무것도 하지 않음
          }

          final updatedFolder = folder.copyWith(
            name: newName,
            updatedAt: DateTime.now(),
          );
          nameController.dispose();
          focusNode.dispose();
          isValidNotifier.dispose();
          Navigator.pop(context, updatedFolder);
        },
        confirmButtonColor: AppColors.primary,
      ),
    );
  }
}

