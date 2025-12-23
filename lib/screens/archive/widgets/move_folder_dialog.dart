// 폴더 위치 변경 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/archive_folder.dart';
import '../../../widgets/dialogs/modern_bottom_sheet.dart';

class MoveFolderDialog {
  static Future<String?> show(
    BuildContext context,
    ArchiveFolder folder,
    List<ArchiveFolder> allFolders,
  ) {
    final currentIndex = allFolders.indexWhere((f) => f.id == folder.id);
    final canMoveLeft = currentIndex > 0;
    final canMoveRight = currentIndex < allFolders.length - 1;

    return ModernBottomSheet.showCustom<String>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '폴더 위치 변경',
        icon: Icons.swap_horiz,
        iconColor: AppColors.primary,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '폴더 위치를 변경하세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // 좌측 이동 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canMoveLeft
                      ? () => Navigator.pop(context, 'left')
                      : null,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                  label: const Text(
                    '좌측 이동',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canMoveLeft
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    foregroundColor: canMoveLeft
                        ? Colors.white
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 우측 이동 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canMoveRight
                      ? () => Navigator.pop(context, 'right')
                      : null,
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 20,
                  ),
                  label: const Text(
                    '우측 이동',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canMoveRight
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    foregroundColor: canMoveRight
                        ? Colors.white
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: ModernBottomSheetActions(
        cancelText: AppStrings.cancel,
        confirmText: null,
        showConfirmButton: false,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

