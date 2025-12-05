// 면접 후기 작성/수정 화면
// 면접 후기를 작성하거나 수정하는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class AddEditInterviewReviewScreen extends StatefulWidget {
  final String companyName;
  final String? position;
  final Map<String, dynamic>? review;
  final int? reviewIndex;

  const AddEditInterviewReviewScreen({
    super.key,
    required this.companyName,
    this.position,
    this.review,
    this.reviewIndex,
  });

  @override
  State<AddEditInterviewReviewScreen> createState() =>
      _AddEditInterviewReviewScreenState();
}

class _AddEditInterviewReviewScreenState
    extends State<AddEditInterviewReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final List<TextEditingController> _questionControllers = [];

  DateTime? _selectedDate;
  int _rating = 3;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.review != null;

    if (_isEdit && widget.review != null) {
      final review = widget.review!;
      _selectedDate = review['date'] as DateTime;
      _dateController.text = _formatDate(_selectedDate!);
      _typeController.text = review['type'] as String;
      _reviewController.text = review['review'] as String;
      _rating = review['rating'] as int;

      final questions = review['questions'] as List<String>;
      for (var question in questions) {
        final controller = TextEditingController(text: question);
        _questionControllers.add(controller);
      }
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = _formatDate(_selectedDate!);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '면접 후기 수정' : AppStrings.writeInterviewReview),
        actions: [
          TextButton(
            onPressed: _saveReview,
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 회사 정보
              _buildCompanyInfo(context),
              const SizedBox(height: 24),

              // 면접 일시
              _buildDateField(context),
              const SizedBox(height: 24),

              // 면접 유형
              _buildTypeField(context),
              const SizedBox(height: 24),

              // 면접 질문
              _buildQuestionsSection(context),
              const SizedBox(height: 24),

              // 면접 후기
              _buildReviewField(context),
              const SizedBox(height: 24),

              // 평가
              _buildRatingSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.business, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.companyName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.position != null)
                    Text(
                      widget.position!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              '${AppStrings.interviewDate} *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              locale: const Locale('ko', 'KR'),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _dateController.text = _formatDate(picked);
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
                  _dateController.text.isEmpty
                      ? AppStrings.selectDate
                      : _dateController.text,
                  style: TextStyle(
                    color: _dateController.text.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              AppStrings.interviewType,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _typeController,
          decoration: InputDecoration(
            hintText: '예: 1차 면접, 2차 면접, 최종 면접',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.interviewQuestions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _questionControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addInterviewQuestion),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_questionControllers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '면접 질문을 추가하려면 [+ 질문 추가] 버튼을 누르세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            _questionControllers.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _questionControllers[index],
                        decoration: InputDecoration(
                          hintText: '질문 ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _questionControllers[index].dispose();
                          _questionControllers.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildReviewField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.note_outlined, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              AppStrings.interviewReviewText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reviewController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '면접 분위기, 느낀 점, 개선할 점 등을 작성하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              AppStrings.rating,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '$_rating / 5',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
          ),
        ),
      ],
    );
  }

  void _saveReview() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('면접 일시를 선택해주세요.')),
        );
        return;
      }

      // TODO: 저장 로직
      // final questions = _questionControllers
      //     .map((controller) => controller.text)
      //     .where((text) => text.isNotEmpty)
      //     .toList();
      //
      // final reviewData = {
      //   'date': _selectedDate,
      //   'type': _typeController.text,
      //   'questions': questions,
      //   'review': _reviewController.text,
      //   'rating': _rating,
      // };

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? '면접 후기가 수정되었습니다.' : '면접 후기가 저장되었습니다.'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
