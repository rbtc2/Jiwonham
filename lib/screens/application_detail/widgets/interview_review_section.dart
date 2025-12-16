// 면접 후기 섹션 위젯
// 면접 후기 목록을 표시하고 새 후기를 추가할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/interview_review.dart';
import '../../../widgets/dialogs/interview_review_dialog.dart';
import 'interview_review_item.dart';

class InterviewReviewSection extends StatelessWidget {
  final Application application;
  final Function(InterviewReview) onReviewAdded;
  final Function(int, InterviewReview) onReviewUpdated;
  final Function(int) onReviewDeleted;

  const InterviewReviewSection({
    super.key,
    required this.application,
    required this.onReviewAdded,
    required this.onReviewUpdated,
    required this.onReviewDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.interviewReview,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '면접 후 기록하는 후기',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.writeInterviewReview),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (application.interviewReviews.isEmpty)
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
                        AppStrings.noInterviewReview,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(application.interviewReviews.length, (index) {
                final review = application.interviewReviews[index];
                return InterviewReviewItem(
                  review: review,
                  onEdit: (updatedReview) {
                    onReviewUpdated(index, updatedReview);
                  },
                  onDelete: () {
                    onReviewDeleted(index);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await InterviewReviewDialog.show(context);
    if (result != null && context.mounted) {
      final newReview = InterviewReview(
        id: result['id'] as String? ?? '',
        date: result['date'] as DateTime,
        type: result['type'] as String,
        questions: List<String>.from(result['questions'] as List),
        review: result['review'] as String,
        rating: result['rating'] as int,
      );
      onReviewAdded(newReview);
    }
  }
}


