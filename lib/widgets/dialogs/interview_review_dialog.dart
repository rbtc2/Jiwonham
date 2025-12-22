// 면접 후기 작성/수정 다이얼로그
// 면접 후기를 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/interview_review.dart';
import '../../utils/date_utils.dart';
import 'modern_bottom_sheet.dart';

class InterviewReviewDialog {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    InterviewReview? review,
  }) {
    final isEdit = review != null;
    final dateController = TextEditingController(
      text: review != null ? formatDate(review.date) : '',
    );
    final typeController = TextEditingController(
      text: review?.type ?? '',
    );
    final reviewController = TextEditingController(
      text: review?.review ?? '',
    );
    int rating = review?.rating ?? 3;
    List<String> questions = review != null
        ? List<String>.from(review.questions)
        : <String>[];
    final List<TextEditingController> questionControllers = questions
        .map((q) => TextEditingController(text: q))
        .toList();

    return ModernBottomSheet.showCustom<Map<String, dynamic>>(
      context: context,
      header: ModernBottomSheetHeader(
        title: isEdit ? '면접 후기 수정' : AppStrings.writeInterviewReview,
        icon: Icons.rate_review,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          void addQuestion() {
            setState(() {
              questions.add('');
              questionControllers.add(TextEditingController());
            });
          }

          void removeQuestion(int index) {
            setState(() {
              questions.removeAt(index);
              questionControllers[index].dispose();
              questionControllers.removeAt(index);
            });
          }

          Future<void> selectDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: review?.date ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              locale: const Locale('ko', 'KR'),
            );
            if (picked != null) {
              setState(() {
                dateController.text = formatDate(picked);
              });
            }
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 선택
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: AppStrings.interviewDate,
                    hintText: AppStrings.selectDate,
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
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  readOnly: true,
                  onTap: selectDate,
                ),
                const SizedBox(height: 20),
                // 면접 유형
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: AppStrings.interviewType,
                    hintText: '예: 1차 면접, 2차 면접, 최종 면접',
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
                // 면접 질문
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.interviewQuestions,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: addQuestion,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppStrings.addInterviewQuestion),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  questionControllers.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: questionControllers[i],
                      decoration: InputDecoration(
                        hintText: '질문 ${i + 1}',
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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => removeQuestion(i),
                          color: AppColors.error,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ),
                if (questionControllers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '면접 질문이 없습니다. 질문을 추가해보세요.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // 면접 후기
                Text(
                  AppStrings.interviewReviewText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reviewController,
                  maxLines: null,
                  minLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: '면접 분위기, 느낀 점, 개선할 점 등을 작성하세요',
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
                // 별점 평가
                Text(
                  AppStrings.rating,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        icon: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: AppColors.warning,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = i + 1;
                          });
                        },
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          // 질문 리스트 업데이트
          final questionsList = questionControllers
              .map((c) => c.text.trim())
              .where((q) => q.isNotEmpty)
              .toList();

          // 날짜 파싱 (YYYY.MM.DD 형식)
          DateTime date;
          try {
            final dateParts = dateController.text.trim().split('.');
            if (dateParts.length == 3) {
              date = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
              );
            } else {
              date = review?.date ?? DateTime.now();
            }
          } catch (e) {
            date = review?.date ?? DateTime.now();
          }

          // 컨트롤러 정리
          dateController.dispose();
          typeController.dispose();
          reviewController.dispose();
          for (var controller in questionControllers) {
            controller.dispose();
          }

          Navigator.pop(context, {
            'id': review?.id,
            'date': date,
            'type': typeController.text.trim(),
            'questions': questionsList,
            'review': reviewController.text.trim(),
            'rating': rating,
          });
        },
      ),
      isScrollControlled: true,
    );
  }
}
