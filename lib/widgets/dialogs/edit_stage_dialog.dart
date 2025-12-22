// 일정 수정 다이얼로그
// 다음 전형 일정을 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/date_utils.dart';
import 'modern_bottom_sheet.dart';

class EditStageDialog {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String initialType,
    required DateTime initialDate,
  }) {
    final typeController = TextEditingController(text: initialType);
    DateTime selectedDate = initialDate;
    final typeFocusNode = FocusNode();

    return ModernBottomSheet.showCustom<Map<String, dynamic>>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '일정 수정',
        icon: Icons.edit_calendar,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          // 첫 번째 필드에 자동 포커스
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (typeFocusNode.canRequestFocus) {
              typeFocusNode.requestFocus();
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.stageType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                focusNode: typeFocusNode,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: AppStrings.stageTypeExample,
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
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.stageDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ko', 'KR'),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(selectedDate),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          if (typeController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('전형 유형을 입력해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          typeController.dispose();
          typeFocusNode.dispose();

          Navigator.pop(context, {
            'type': typeController.text.trim(),
            'date': selectedDate,
          });
        },
      ),
    );
  }
}
