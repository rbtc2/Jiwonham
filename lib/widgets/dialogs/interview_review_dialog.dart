// 면접 후기 작성/수정 다이얼로그
// 면접 후기를 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/interview_review.dart';
import '../../utils/date_utils.dart';

class InterviewReviewDialog extends StatefulWidget {
  final InterviewReview? review;

  const InterviewReviewDialog({
    super.key,
    this.review,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    InterviewReview? review,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => InterviewReviewDialog(review: review),
    );
  }

  @override
  State<InterviewReviewDialog> createState() => _InterviewReviewDialogState();
}

class _InterviewReviewDialogState extends State<InterviewReviewDialog> {
  late TextEditingController _dateController;
  late TextEditingController _typeController;
  late TextEditingController _reviewController;
  late int _rating;
  late List<String> _questions;
  late List<TextEditingController> _questionControllers;

  bool get _isEdit => widget.review != null;

  @override
  void initState() {
    super.initState();
    final review = widget.review;
    _dateController = TextEditingController(
      text: review != null ? formatDate(review.date) : '',
    );
    _typeController = TextEditingController(
      text: review?.type ?? '',
    );
    _reviewController = TextEditingController(
      text: review?.review ?? '',
    );
    _rating = review?.rating ?? 3;
    _questions = review != null
        ? List<String>.from(review.questions)
        : <String>[];
    _questionControllers = _questions
        .map((q) => TextEditingController(text: q))
        .toList();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _typeController.dispose();
    _reviewController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add('');
      _questionControllers.add(TextEditingController());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _questionControllers[index].dispose();
      _questionControllers.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.review?.date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateController.text = formatDate(picked);
      });
    }
  }

  void _save() {
    // 질문 리스트 업데이트
    final questions = _questionControllers
        .map((c) => c.text.trim())
        .where((q) => q.isNotEmpty)
        .toList();

    // 날짜 파싱 (YYYY.MM.DD 형식)
    DateTime date;
    try {
      final dateParts = _dateController.text.trim().split('.');
      if (dateParts.length == 3) {
        date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
      } else {
        // 파싱 실패 시 기존 날짜 또는 현재 날짜 사용
        date = widget.review?.date ?? DateTime.now();
      }
    } catch (e) {
      // 파싱 실패 시 기존 날짜 또는 현재 날짜 사용
      date = widget.review?.date ?? DateTime.now();
    }

    Navigator.pop(context, {
      'id': widget.review?.id,
      'date': date,
      'type': _typeController.text.trim(),
      'questions': questions,
      'review': _reviewController.text.trim(),
      'rating': _rating,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          _isEdit ? '면접 후기 수정' : AppStrings.writeInterviewReview,
        ),
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
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: AppStrings.interviewType,
                  hintText: '예: 1차 면접, 2차 면접, 최종 면접',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.interviewQuestions,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _questionControllers.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _questionControllers[i],
                    decoration: InputDecoration(
                      hintText: '질문 ${i + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setDialogState(() {
                            _removeQuestion(i);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setDialogState(() {
                    _addQuestion();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addInterviewQuestion),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.interviewReviewText,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '면접 분위기, 느낀 점, 개선할 점 등을 작성하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.rating,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        _rating = i + 1;
                      });
                    },
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
            onPressed: _save,
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}

