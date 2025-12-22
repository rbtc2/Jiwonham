// 면접 후기 탭 위젯
// 면접 준비 섹션과 면접 후기 목록을 표시하는 탭

import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/interview_review.dart';
import 'interview_preparation_section.dart';
import 'interview_review_section.dart';

class InterviewReviewTab extends StatelessWidget {
  final Application application;
  final Function(InterviewReview) onReviewAdded;
  final Function(int, InterviewReview) onReviewUpdated;
  final Function(int) onReviewDeleted;

  const InterviewReviewTab({
    super.key,
    required this.application,
    required this.onReviewAdded,
    required this.onReviewUpdated,
    required this.onReviewDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 면접 준비 섹션
          const InterviewPreparationSection(),
          const SizedBox(height: 16),
          // 면접 후기 섹션
          InterviewReviewSection(
            application: application,
            onReviewAdded: onReviewAdded,
            onReviewUpdated: onReviewUpdated,
            onReviewDeleted: onReviewDeleted,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}






