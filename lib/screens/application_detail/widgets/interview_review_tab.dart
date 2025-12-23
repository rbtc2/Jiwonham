// 면접 후기 탭 위젯
// 면접 후기를 표시하고 관리하는 탭

import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/interview_review.dart';
import '../../../models/interview_question.dart';
import 'interview_review_section.dart';
import 'interview_question_section.dart';

class InterviewReviewTab extends StatelessWidget {
  final Application application;
  final Function(InterviewReview) onReviewAdded;
  final Function(int, InterviewReview) onReviewUpdated;
  final Function(int) onReviewDeleted;
  final Function(InterviewQuestion) onQuestionAdded;
  final Function(int, InterviewQuestion) onQuestionUpdated;
  final Function(int, InterviewQuestion) onAnswerUpdated;
  final Function(int) onQuestionDeleted;

  const InterviewReviewTab({
    super.key,
    required this.application,
    required this.onReviewAdded,
    required this.onReviewUpdated,
    required this.onReviewDeleted,
    required this.onQuestionAdded,
    required this.onQuestionUpdated,
    required this.onAnswerUpdated,
    required this.onQuestionDeleted,
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
          InterviewQuestionSection(
            application: application,
            onQuestionAdded: onQuestionAdded,
            onQuestionUpdated: onQuestionUpdated,
            onAnswerUpdated: onAnswerUpdated,
            onQuestionDeleted: onQuestionDeleted,
          ),
          const SizedBox(height: 12),
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
