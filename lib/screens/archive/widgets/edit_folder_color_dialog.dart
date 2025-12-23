// 폴더 색상 변경 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/archive_folder.dart';
import '../../../widgets/dialogs/modern_bottom_sheet.dart';

class EditFolderColorDialog {
  static Future<ArchiveFolder?> show(
    BuildContext context,
    ArchiveFolder folder,
  ) {
    final selectedColorNotifier = ValueNotifier<Color>(Color(folder.color));
    
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

    return ModernBottomSheet.showCustom<ArchiveFolder>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '폴더 색상 변경',
        icon: Icons.palette_outlined,
        iconColor: AppColors.primary,
      ),
      content: ValueListenableBuilder<Color>(
        valueListenable: selectedColorNotifier,
        builder: (context, selectedColor, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '폴더 색상을 선택하세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
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
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        cancelText: AppStrings.cancel,
        confirmText: '변경',
        onCancel: () {
          selectedColorNotifier.dispose();
          Navigator.pop(context);
        },
        onConfirm: () {
          final selectedColor = selectedColorNotifier.value;
          if (selectedColor.toARGB32() == folder.color) {
            selectedColorNotifier.dispose();
            Navigator.pop(context);
            return;
          }

          final updatedFolder = folder.copyWith(
            color: selectedColor.toARGB32(),
            updatedAt: DateTime.now(),
          );
          selectedColorNotifier.dispose();
          Navigator.pop(context, updatedFolder);
        },
        confirmButtonColor: AppColors.primary,
      ),
    );
  }
}

