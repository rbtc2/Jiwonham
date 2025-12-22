// 일정 추가 다이얼로그
// 다음 전형 일정을 추가하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/date_utils.dart';

class AddStageDialog extends StatefulWidget {
  const AddStageDialog({super.key});

  @override
  State<AddStageDialog> createState() => _AddStageDialogState();
}

class _AddStageDialogState extends State<AddStageDialog> {
  final TextEditingController _typeController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addStage),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.stageType,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: AppStrings.stageTypeExample,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.stageDate,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('ko', 'KR'),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? formatDate(_selectedDate!)
                          : AppStrings.selectDate,
                      style: TextStyle(
                        color: _selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_typeController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('전형 유형을 입력해주세요.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            if (_selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('일정을 선택해주세요.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'type': _typeController.text.trim(),
              'date': _selectedDate!,
            });
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}







