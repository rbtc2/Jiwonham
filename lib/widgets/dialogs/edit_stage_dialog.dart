// 일정 수정 다이얼로그
// 다음 전형 일정을 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/date_utils.dart';

class EditStageDialog extends StatefulWidget {
  final String initialType;
  final DateTime initialDate;

  const EditStageDialog({
    super.key,
    required this.initialType,
    required this.initialDate,
  });

  @override
  State<EditStageDialog> createState() => _EditStageDialogState();
}

class _EditStageDialogState extends State<EditStageDialog> {
  late final TextEditingController _typeController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.initialType);
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일정 수정'),
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
                  initialDate: _selectedDate,
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
                      formatDate(_selectedDate),
                      style: const TextStyle(color: AppColors.textPrimary),
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

            Navigator.pop(context, {
              'type': _typeController.text.trim(),
              'date': _selectedDate,
            });
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}


