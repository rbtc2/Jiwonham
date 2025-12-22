// 면접 일정 다이얼로그
// 면접 일정을 설정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';

class InterviewScheduleDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialLocation;
  final Function(DateTime?, String?) onSave;

  const InterviewScheduleDialog({
    super.key,
    this.initialDate,
    this.initialLocation,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    String? initialLocation,
    required Function(DateTime?, String?) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => InterviewScheduleDialog(
        initialDate: initialDate,
        initialLocation: initialLocation,
        onSave: onSave,
      ),
    );
  }

  @override
  State<InterviewScheduleDialog> createState() =>
      _InterviewScheduleDialogState();
}

class _InterviewScheduleDialogState extends State<InterviewScheduleDialog> {
  late final TextEditingController _dateController;
  late final TextEditingController _locationController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _dateController = TextEditingController(
      text: widget.initialDate != null ? _formatDate(widget.initialDate!) : '',
    );
    _locationController = TextEditingController(
      text: widget.initialLocation ?? '',
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('.');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.interviewSchedule),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: AppStrings.interviewDate,
                hintText: AppStrings.selectDate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('ko', 'KR'),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _dateController.text = _formatDate(picked);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: AppStrings.interviewLocation,
                hintText: '면접 장소를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final date = _dateController.text.isNotEmpty
                ? _parseDate(_dateController.text)
                : null;
            final location = _locationController.text.trim();
            widget.onSave(
              date,
              location.isNotEmpty ? location : null,
            );
            Navigator.pop(context);
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

