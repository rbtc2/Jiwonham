// 면접 준비 섹션 위젯
// 면접 질문, 체크리스트, 면접 일정을 포함하는 섹션

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_strings.dart';
import '../application_detail_view_model.dart';
import 'interview_questions_section.dart';
import 'interview_checklist_section.dart';
import 'interview_schedule_section.dart';

class InterviewPreparationSection extends StatelessWidget {
  const InterviewPreparationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationDetailViewModel>(
      builder: (context, viewModel, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.interviewPreparation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                // 면접 질문 준비
                InterviewQuestionsSection(viewModel: viewModel),
                const SizedBox(height: 16),
                // 체크리스트
                InterviewChecklistSection(viewModel: viewModel),
                const SizedBox(height: 16),
                // 면접 일정 정보
                InterviewScheduleSection(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }
}

