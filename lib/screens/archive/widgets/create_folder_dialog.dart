// 폴더 생성 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/archive_folder.dart';
import '../../../widgets/dialogs/modern_bottom_sheet.dart';

class CreateFolderDialog {
  static Future<ArchiveFolder?> show(BuildContext context, int? nextOrder) {
    final nameController = TextEditingController();
    final selectedColorNotifier = ValueNotifier<Color>(AppColors.primary);
    final isValidNotifier = ValueNotifier<bool>(false);
    final focusNode = FocusNode();

    final List<Color> colorOptions = [
      AppColors.primary,
      const Color(0xFFF44336), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFEB3B), // Yellow
    ];

    // 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });

    // 이름 변경 감지
    nameController.addListener(() {
      final isValid = nameController.text.trim().isNotEmpty;
      if (isValidNotifier.value != isValid) {
        isValidNotifier.value = isValid;
      }
    });

    return ModernBottomSheet.showCustom<ArchiveFolder>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '새 폴더 만들기',
        icon: Icons.create_new_folder_outlined,
        iconColor: AppColors.primary,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 폴더 이름 입력
          TextField(
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
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
            onSubmitted: (_) {
              if (isValidNotifier.value) {
                final selectedColor = selectedColorNotifier.value;
                final folder = ArchiveFolder(
                  id: 'folder_${DateTime.now().millisecondsSinceEpoch}_${nameController.text.trim().hashCode}',
                  name: nameController.text.trim(),
                  color: selectedColor.toARGB32(),
                  order: nextOrder ?? 0,
                );
                nameController.dispose();
                focusNode.dispose();
                selectedColorNotifier.dispose();
                isValidNotifier.dispose();
                Navigator.pop(context, folder);
              }
            },
          ),
          const SizedBox(height: 24),
          // 폴더 색상 선택
          Text(
            '폴더 색상',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<Color>(
            valueListenable: selectedColorNotifier,
            builder: (context, selectedColor, _) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: colorOptions.map((color) {
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () {
                      selectedColorNotifier.value = color;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: isSelected ? 3 : 0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      actions: ModernBottomSheetActions(
        cancelText: AppStrings.cancel,
        confirmText: '만들기',
        onCancel: () {
          nameController.dispose();
          focusNode.dispose();
          selectedColorNotifier.dispose();
          isValidNotifier.dispose();
          Navigator.pop(context);
        },
        onConfirm: () {
          if (!isValidNotifier.value) {
            return; // 유효하지 않으면 아무것도 하지 않음
          }

          final selectedColor = selectedColorNotifier.value;
          final folder = ArchiveFolder(
            id: 'folder_${DateTime.now().millisecondsSinceEpoch}_${nameController.text.trim().hashCode}',
            name: nameController.text.trim(),
            color: selectedColor.toARGB32(),
            order: nextOrder ?? 0,
          );
          nameController.dispose();
          focusNode.dispose();
          selectedColorNotifier.dispose();
          isValidNotifier.dispose();
          Navigator.pop(context, folder);
        },
        confirmButtonColor: AppColors.primary,
      ),
    );
  }
}
