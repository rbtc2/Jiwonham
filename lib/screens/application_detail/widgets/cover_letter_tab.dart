// 자기소개서 탭 위젯
// 자기소개서 문항과 답변을 표시하는 탭

import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/cover_letter_question.dart';
import 'cover_letter_section.dart';

class CoverLetterTab extends StatelessWidget {
  final Application application;
  final Function(int, String) onAnswerUpdated;
  final Function(CoverLetterQuestion) onQuestionAdded;

  const CoverLetterTab({
    super.key,
    required this.application,
    required this.onAnswerUpdated,
    required this.onQuestionAdded,
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
          CoverLetterSection(
            application: application,
            onAnswerUpdated: onAnswerUpdated,
            onQuestionAdded: onQuestionAdded,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}







