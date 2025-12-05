// 공고 상세 화면
// 선택한 공고의 모든 정보를 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공고 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 수정 화면으로 이동
            },
            tooltip: '수정',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: 삭제 확인 다이얼로그
            },
            tooltip: '삭제',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보 카드
            _buildBasicInfoCard(context),
            const SizedBox(height: 16),

            // 지원 정보 섹션
            _buildApplicationInfoSection(context),
            const SizedBox(height: 16),

            // 자기소개서 문항 섹션
            _buildCoverLetterSection(context),
            const SizedBox(height: 16),

            // 면접 후기 섹션
            _buildInterviewReviewSection(context),
            const SizedBox(height: 16),

            // 메모 섹션
            _buildMemoSection(context),
            const SizedBox(height: 16),

            // 상태 변경 섹션
            _buildStatusSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    final deadline = DateTime.now().add(const Duration(days: 5));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '회사명',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '직무명',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                DDayBadge(deadline: deadline),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 지원서 링크 열기
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('지원서 링크 열기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // TODO: 알림 설정
                  },
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: '알림 설정',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지원 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.calendar_today, '서류 마감일', '2024.01.20', 'D-5'),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.campaign, '서류 발표일', '2024.01.25', null),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.event, '다음 전형 일정', '면접: 2024.01.30', null),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.event, '', '최종: 2024.02.05', null),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    String? badge,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverLetterSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.coverLetterQuestions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildQuestionItem(context, '1. 지원동기 (500자)', '작성하기'),
            const Divider(height: 16),
            _buildQuestionItem(context, '2. 입사 후 포부 (300자)', '작성하기'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(BuildContext context, String question, String action) {
    return InkWell(
      onTap: () {
        // TODO: 자기소개서 작성 화면으로 이동
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                question,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 작성 화면으로 이동
              },
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewReviewSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '면접 후기',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 면접 후기 작성 화면으로 이동
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('면접 후기 작성'),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                      '면접 후기가 없습니다. 면접 후기를 작성해보세요.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
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

  Widget _buildMemoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.memo,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '메모 내용이 여기에 표시됩니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상태 변경',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatusRadio(context, ApplicationStatus.notApplied, '지원 전'),
            _buildStatusRadio(context, ApplicationStatus.applied, '지원 완료'),
            _buildStatusRadio(context, ApplicationStatus.inProgress, '진행중'),
            _buildStatusRadio(context, ApplicationStatus.passed, '합격'),
            _buildStatusRadio(context, ApplicationStatus.rejected, '불합격'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRadio(
    BuildContext context,
    ApplicationStatus status,
    String label,
  ) {
    return RadioListTile<ApplicationStatus>(
      title: Row(
        children: [
          StatusChip(status: status),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      value: status,
      groupValue: ApplicationStatus.inProgress, // TODO: 실제 상태로 교체
      onChanged: (value) {
        // TODO: 상태 변경 로직
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
