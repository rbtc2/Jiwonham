// 공고 상세 화면
// 선택한 공고의 모든 정보를 보여주는 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../models/interview_question.dart';
import '../../models/interview_checklist.dart';
import '../../models/notification_settings.dart';
import '../../widgets/dialogs/notification_settings_dialog.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import 'application_detail_view_model.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with SingleTickerProviderStateMixin {
  // 탭 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Phase 1: 지원서 링크 열기
  Future<void> _openApplicationLink(String link) async {
    try {
      Uri uri = Uri.parse(link);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$link');
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크를 열 수 없습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ApplicationDetailViewModel(application: widget.application),
      child: Consumer<ApplicationDetailViewModel>(
        builder: (context, viewModel, _) {
          return PopScope(
            canPop: !viewModel.hasChanges,
            onPopInvokedWithResult: (didPop, result) {
              // 뒤로 가기 시 변경사항이 있으면 true 반환하여 이전 화면이 새로고침되도록 함
              if (!didPop && viewModel.hasChanges) {
                Navigator.of(context).pop(true);
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text(AppStrings.applicationDetail),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditApplicationScreen(
                            application: viewModel.application,
                          ),
                        ),
                      ).then((result) {
                        // 수정 완료 후 화면 새로고침
                        if (result == true && mounted) {
                          viewModel.loadApplication();
                        }
                      });
                    },
                    tooltip: AppStrings.edit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _showDeleteConfirmDialog(context);
                    },
                    tooltip: AppStrings.delete,
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '정보'),
                    Tab(text: '서류 단계'),
                    Tab(text: '면접 단계'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  // 정보 탭: 기본 정보, 지원 정보, 메모, 상태 변경
                  _buildInfoTab(context, viewModel),
                  // 자기소개서 탭
                  _buildCoverLetterTab(context, viewModel),
                  // 면접 후기 탭
                  _buildInterviewReviewTab(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 정보 탭 빌드
  Widget _buildInfoTab(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보 카드
          _buildBasicInfoCard(context, viewModel),
          const SizedBox(height: 16),

          // 지원 정보 섹션
          _buildApplicationInfoSection(context, viewModel),
          const SizedBox(height: 16),

          // 메모 섹션
          _buildMemoSection(context, viewModel),
          const SizedBox(height: 16),

          // 상태 변경 섹션
          _buildStatusSection(context, viewModel),
          // 하단 패딩 추가 (스크롤이 끝까지 내려가도록)
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // 자기소개서 탭 빌드
  Widget _buildCoverLetterTab(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 자기소개서 문항 섹션
          _buildCoverLetterSection(context, viewModel),
          // 하단 패딩 추가
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // 면접 후기 탭 빌드
  Widget _buildInterviewReviewTab(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 면접 준비 섹션
          _buildInterviewPreparationSection(context, viewModel),
          const SizedBox(height: 16),
          // 면접 후기 섹션
          _buildInterviewReviewSection(context, viewModel),
          // 하단 패딩 추가
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
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
                        viewModel.application.companyName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (viewModel.application.position != null &&
                          viewModel.application.position!.isNotEmpty)
                        Text(
                          viewModel.application.position!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
                DDayBadge(deadline: viewModel.application.deadline),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.application.applicationLink != null
                        ? () {
                            // 지원서 링크 열기
                            _openApplicationLink(
                              viewModel.application.applicationLink!,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.link),
                    label: const Text(AppStrings.openLink),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _showNotificationSettingsDialog(context, viewModel);
                  },
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: AppStrings.notificationSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationInfoSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지원 정보',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              '서류 마감일',
              _formatDate(viewModel.application.deadline),
              'D-${viewModel.application.daysUntilDeadline}',
            ),
            if (viewModel.application.announcementDate != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                context,
                Icons.campaign,
                '서류 발표일',
                _formatDate(viewModel.application.announcementDate!),
                null,
              ),
            ],
            if (viewModel.application.nextStages.isNotEmpty) ...[
              const Divider(height: 24),
              ...viewModel.application.nextStages.map((stage) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildInfoRow(
                    context,
                    Icons.event,
                    stage.type,
                    _formatDate(stage.date),
                    null,
                  ),
                );
              }),
            ],
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
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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

  Widget _buildCoverLetterSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
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
                        AppStrings.coverLetterAnswers,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '문항은 수정 화면에서 관리할 수 있습니다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (viewModel.application.coverLetterQuestions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        AppStrings.noCoverLetterQuestions,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.editQuestionToAdd,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                viewModel.application.coverLetterQuestions.length,
                (index) {
                  final question =
                      viewModel.application.coverLetterQuestions[index];
                  final hasAnswer = question.hasAnswer;
                  return Column(
                    children: [
                      _buildQuestionItem(
                        context,
                        question.question,
                        question.answer ?? '',
                        question.maxLength,
                        question.answerLength,
                        hasAnswer,
                        index,
                        viewModel,
                      ),
                      if (index <
                          viewModel.application.coverLetterQuestions.length - 1)
                        const Divider(height: 16),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(
    BuildContext context,
    String question,
    String answer,
    int maxLength,
    int currentLength,
    bool hasAnswer,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    return InkWell(
      onTap: () {
        _showCoverLetterDialog(
          context,
          question,
          answer,
          maxLength,
          index,
          viewModel,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showCoverLetterDialog(
                      context,
                      question,
                      answer,
                      maxLength,
                      index,
                      viewModel,
                    );
                  },
                  child: Text(
                    hasAnswer ? AppStrings.editAnswer : AppStrings.writeAnswer,
                  ),
                ),
              ],
            ),
            if (hasAnswer) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentLength / $maxLength ${AppStrings.characterCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 면접 준비 섹션 빌드
  Widget _buildInterviewPreparationSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.interviewPreparation,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 면접 질문 준비
            _buildInterviewQuestionsSection(context, viewModel),
            const SizedBox(height: 16),
            // 체크리스트
            _buildInterviewChecklistSection(context, viewModel),
            const SizedBox(height: 16),
            // 면접 일정 정보
            _buildInterviewScheduleSection(context, viewModel),
          ],
        ),
      ),
    );
  }

  // 면접 질문 준비 섹션
  Widget _buildInterviewQuestionsSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interviewQuestionsPrep,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                _showAddInterviewQuestionDialog(context, viewModel);
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.addInterviewPrepQuestion),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.application.interviewQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
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
                    AppStrings.noInterviewQuestions,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(viewModel.application.interviewQuestions.length, (
            index,
          ) {
            final question = viewModel.application.interviewQuestions[index];
            return _buildInterviewQuestionItem(
              context,
              question,
              index,
              viewModel,
            );
          }),
      ],
    );
  }

  // 면접 질문 아이템
  Widget _buildInterviewQuestionItem(
    BuildContext context,
    InterviewQuestion question,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  question.question,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      _showEditInterviewQuestionDialog(
                        context,
                        question,
                        index,
                        viewModel,
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () async {
                      final success = await viewModel.deleteInterviewQuestion(
                        index,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('면접 질문이 삭제되었습니다.'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              viewModel.errorMessage ?? '삭제에 실패했습니다.',
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
          if (question.hasAnswer) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                _showInterviewAnswerDialog(context, question, index, viewModel);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.answer!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.editInterviewAnswer,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                _showInterviewAnswerDialog(context, question, index, viewModel);
              },
              child: Text(AppStrings.writeInterviewAnswer),
            ),
          ],
        ],
      ),
    );
  }

  // 체크리스트 섹션
  Widget _buildInterviewChecklistSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interviewChecklist,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                _showAddChecklistItemDialog(context, viewModel);
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.addChecklistItem),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.application.interviewChecklist.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
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
                    AppStrings.noChecklistItems,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(viewModel.application.interviewChecklist.length, (
            index,
          ) {
            final item = viewModel.application.interviewChecklist[index];
            return _buildChecklistItem(context, item, index, viewModel);
          }),
      ],
    );
  }

  // 체크리스트 아이템
  Widget _buildChecklistItem(
    BuildContext context,
    InterviewChecklist item,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (value) async {
              final success = await viewModel.toggleChecklistItem(
                index,
                value ?? false,
              );
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? '업데이트에 실패했습니다.'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: Text(
              item.item,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? AppColors.textSecondary : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () {
              _showEditChecklistItemDialog(context, item, index, viewModel);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () async {
              final success = await viewModel.deleteChecklistItem(index);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('체크리스트 항목이 삭제되었습니다.'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? '삭제에 실패했습니다.'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  // 면접 일정 정보 섹션
  Widget _buildInterviewScheduleSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.interviewSchedule,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _showInterviewScheduleDialog(context, viewModel);
              },
              child: Text(
                viewModel.application.interviewSchedule?.hasSchedule == true
                    ? '수정'
                    : '설정',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (viewModel.application.interviewSchedule?.hasSchedule != true)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
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
                    AppStrings.noInterviewSchedule,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.application.interviewSchedule?.date != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(
                          viewModel.application.interviewSchedule!.date!,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (viewModel.application.interviewSchedule?.location != null &&
                    viewModel
                        .application
                        .interviewSchedule!
                        .location!
                        .isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.application.interviewSchedule!.location!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInterviewReviewSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
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
                  onPressed: () {
                    _showInterviewReviewDialog(context, viewModel);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.writeInterviewReview),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (viewModel.application.interviewReviews.isEmpty)
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
              ...List.generate(viewModel.application.interviewReviews.length, (
                index,
              ) {
                final review = viewModel.application.interviewReviews[index];
                return _buildInterviewReviewItem(
                  context,
                  review,
                  index,
                  viewModel,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewReviewItem(
    BuildContext context,
    dynamic review, // Phase 1: 임시로 dynamic 사용 (InterviewReview 또는 Map)
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    // Phase 1: InterviewReview 객체인지 Map인지 확인
    final date = review is InterviewReview
        ? review.date
        : (review as Map<String, dynamic>)['date'] as DateTime;
    final type = review is InterviewReview
        ? review.type
        : (review as Map<String, dynamic>)['type'] as String;
    final questions = review is InterviewReview
        ? review.questions
        : (review as Map<String, dynamic>)['questions'] as List<String>;
    final reviewText = review is InterviewReview
        ? review.review
        : (review as Map<String, dynamic>)['review'] as String;
    final rating = review is InterviewReview
        ? review.rating
        : (review as Map<String, dynamic>)['rating'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (questions.isNotEmpty) ...[
            Text(
              AppStrings.interviewQuestions,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...questions.map((q) {
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Expanded(
                      child: Text(
                        q,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          Text(
            AppStrings.interviewReviewText,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(reviewText, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _showInterviewReviewDialog(
                    context,
                    viewModel,
                    review: review,
                    index: index,
                  );
                },
                child: const Text('수정'),
              ),
              TextButton(
                onPressed: () async {
                  final success = await viewModel.deleteInterviewReview(index);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('면접 후기가 삭제되었습니다.'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(viewModel.errorMessage ?? '삭제에 실패했습니다.'),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('삭제', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
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
                        AppStrings.progressMemo,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '지원 과정 중 빠르게 기록하는 메모',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showMemoDialog(context, viewModel);
                  },
                  child: const Text(AppStrings.editProgressMemo),
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
              child: Text(
                viewModel.application.memo != null &&
                        viewModel.application.memo!.isNotEmpty
                    ? viewModel.application.memo!
                    : AppStrings.noMemo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      viewModel.application.memo != null &&
                          viewModel.application.memo!.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.changeStatus,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '지원 과정의 진행 상황을 추적합니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioGroup<ApplicationStatus>(
              groupValue: viewModel.application.status,
              onChanged: (value) async {
                if (value != null) {
                  final statusText = await viewModel.updateStatus(value);
                  if (statusText != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('상태가 "$statusText"로 변경되었습니다.'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          viewModel.errorMessage ?? '상태 변경에 실패했습니다.',
                        ),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Column(
                children: [
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.notApplied,
                    AppStrings.notAppliedStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.applied,
                    AppStrings.appliedStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.inProgress,
                    AppStrings.inProgressStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.passed,
                    AppStrings.passedStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.rejected,
                    AppStrings.rejectedStatus,
                  ),
                ],
              ),
            ),
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
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteConfirm),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 삭제 로직
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('공고가 삭제되었습니다.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showCoverLetterDialog(
    BuildContext context,
    String question,
    String answer,
    int maxLength,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    final controller = TextEditingController(text: answer);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(question),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 10,
                  maxLength: maxLength,
                  decoration: InputDecoration(
                    hintText: '답변을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.text.length} / $maxLength ${AppStrings.characterCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
              onPressed: () async {
                final success = await viewModel.updateCoverLetterAnswer(
                  index,
                  controller.text,
                );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('답변이 저장되었습니다.'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage ?? '저장에 실패했습니다.'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showInterviewReviewDialog(
    BuildContext context,
    ApplicationDetailViewModel viewModel, {
    dynamic review,
    int? index,
  }) {
    final isEdit = review != null && index != null;

    // review가 InterviewReview 객체인지 Map인지 확인
    DateTime? reviewDate;
    String reviewType = '';
    String reviewText = '';
    int rating = 3;
    List<String> questions = [];

    if (isEdit && review != null) {
      if (review is InterviewReview) {
        reviewDate = review.date;
        reviewType = review.type;
        reviewText = review.review;
        rating = review.rating;
        questions = List<String>.from(review.questions);
      } else if (review is Map<String, dynamic>) {
        reviewDate = review['date'] as DateTime;
        reviewType = review['type'] as String;
        reviewText = review['review'] as String;
        rating = review['rating'] as int;
        questions = List<String>.from(review['questions'] as List);
      }
    }

    final dateController = TextEditingController(
      text: isEdit && reviewDate != null ? _formatDate(reviewDate) : '',
    );
    final typeController = TextEditingController(text: reviewType);
    final reviewController = TextEditingController(text: reviewText);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? '면접 후기 수정' : AppStrings.writeInterviewReview),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: dateController,
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
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                      locale: const Locale('ko', 'KR'),
                    );
                    if (picked != null) {
                      dateController.text = _formatDate(picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  questions.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: TextEditingController(text: questions[i]),
                      decoration: InputDecoration(
                        hintText: '질문 ${i + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setDialogState(() {
                              questions.removeAt(i);
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        questions[i] = value;
                      },
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      questions.add('');
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addInterviewQuestion),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.interviewReviewText,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = i + 1;
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
              onPressed: () async {
                final parsedDate = _parseDate(dateController.text);
                if (parsedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('날짜를 올바르게 입력해주세요.'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                String reviewId;
                if (isEdit && review != null) {
                  if (review is InterviewReview) {
                    reviewId = review.id;
                  } else if (review is Map<String, dynamic>) {
                    reviewId = review['id'] as String;
                  } else {
                    reviewId = DateTime.now().millisecondsSinceEpoch.toString();
                  }
                } else {
                  reviewId = DateTime.now().millisecondsSinceEpoch.toString();
                }

                final interviewReview = InterviewReview(
                  id: reviewId,
                  date: parsedDate,
                  type: typeController.text.trim(),
                  questions: questions
                      .where((q) => q.trim().isNotEmpty)
                      .toList(),
                  review: reviewController.text.trim(),
                  rating: rating,
                );

                bool success;
                if (isEdit) {
                  success = await viewModel.updateInterviewReview(
                    index,
                    interviewReview,
                  );
                } else {
                  success = await viewModel.addInterviewReview(interviewReview);
                }

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit ? '면접 후기가 수정되었습니다.' : '면접 후기가 추가되었습니다.',
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage ?? '저장에 실패했습니다.'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemoDialog(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    final controller = TextEditingController(
      text: viewModel.application.memo ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editMemo),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '메모를 입력하세요',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onPressed: () async {
              final success = await viewModel.updateMemo(controller.text);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('메모가 저장되었습니다.'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? '저장에 실패했습니다.'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  // 면접 질문 추가 다이얼로그
  void _showAddInterviewQuestionDialog(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    final questionController = TextEditingController();
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.addInterviewPrepQuestion,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 입력 필드
                TextField(
                  controller: questionController,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  minLines: 6,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText:
                        '예상 면접 질문을 입력하세요\n\n예: "자기소개를 해주세요"\n예: "이 회사를 지원한 이유는 무엇인가요?"',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
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
                const SizedBox(height: 24),
                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (questionController.text.trim().isNotEmpty) {
                            final success = await viewModel
                                .addInterviewQuestion(
                                  questionController.text.trim(),
                                );
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('면접 질문이 추가되었습니다.'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage ?? '추가에 실패했습니다.',
                                  ),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      focusNode.dispose();
    });
  }

  // 면접 질문 수정 다이얼로그
  void _showEditInterviewQuestionDialog(
    BuildContext context,
    InterviewQuestion question,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    final questionController = TextEditingController(text: question.question);
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.editInterviewPrepQuestion,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 입력 필드
                TextField(
                  controller: questionController,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  minLines: 6,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText:
                        '예상 면접 질문을 입력하세요\n\n예: "자기소개를 해주세요"\n예: "이 회사를 지원한 이유는 무엇인가요?"',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
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
                const SizedBox(height: 24),
                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (questionController.text.trim().isNotEmpty) {
                            final success = await viewModel
                                .updateInterviewQuestion(
                                  index,
                                  questionController.text.trim(),
                                );
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('면접 질문이 수정되었습니다.'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage ?? '수정에 실패했습니다.',
                                  ),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      focusNode.dispose();
    });
  }

  // 면접 답변 작성/수정 다이얼로그
  void _showInterviewAnswerDialog(
    BuildContext context,
    InterviewQuestion question,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    final answerController = TextEditingController(text: question.answer ?? '');
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.question,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 입력 필드
                TextField(
                  controller: answerController,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  minLines: 10,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '답변을 입력하세요\n\n면접에서 말할 답변을 미리 작성해보세요.',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
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
                const SizedBox(height: 24),
                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await viewModel.updateInterviewAnswer(
                            index,
                            answerController.text.trim(),
                          );
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('면접 답변이 저장되었습니다.'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  viewModel.errorMessage ?? '저장에 실패했습니다.',
                                ),
                                backgroundColor: AppColors.error,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      focusNode.dispose();
    });
  }

  // 체크리스트 항목 추가 다이얼로그
  void _showAddChecklistItemDialog(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    final itemController = TextEditingController();
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.checklist,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.addChecklistItem,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 입력 필드
                TextField(
                  controller: itemController,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText:
                        '체크리스트 항목을 입력하세요\n\n예: "이력서 3부 준비"\n예: "포트폴리오 출력"',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
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
                const SizedBox(height: 24),
                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (itemController.text.trim().isNotEmpty) {
                            final success = await viewModel.addChecklistItem(
                              itemController.text.trim(),
                            );
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('체크리스트 항목이 추가되었습니다.'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage ?? '추가에 실패했습니다.',
                                  ),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      focusNode.dispose();
    });
  }

  // 체크리스트 항목 수정 다이얼로그
  void _showEditChecklistItemDialog(
    BuildContext context,
    InterviewChecklist item,
    int index,
    ApplicationDetailViewModel viewModel,
  ) {
    final itemController = TextEditingController(text: item.item);
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 제목
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.editChecklistItem,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 입력 필드
                TextField(
                  controller: itemController,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText:
                        '체크리스트 항목을 입력하세요\n\n예: "이력서 3부 준비"\n예: "포트폴리오 출력"',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
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
                const SizedBox(height: 24),
                // 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (itemController.text.trim().isNotEmpty) {
                            final success = await viewModel.updateChecklistItem(
                              index,
                              itemController.text.trim(),
                            );
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('체크리스트 항목이 수정되었습니다.'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage ?? '수정에 실패했습니다.',
                                  ),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      focusNode.dispose();
    });
  }

  // 면접 일정 설정 다이얼로그
  void _showInterviewScheduleDialog(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    final dateController = TextEditingController(
      text: viewModel.application.interviewSchedule?.date != null
          ? _formatDate(viewModel.application.interviewSchedule!.date!)
          : '',
    );
    final locationController = TextEditingController(
      text: viewModel.application.interviewSchedule?.location ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.interviewSchedule),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: dateController,
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
                    initialDate:
                        viewModel.application.interviewSchedule?.date ??
                        DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ko', 'KR'),
                  );
                  if (picked != null) {
                    dateController.text = _formatDate(picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
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
            onPressed: () async {
              final date = dateController.text.isNotEmpty
                  ? _parseDate(dateController.text)
                  : null;
              final location = locationController.text.trim();
              final success = await viewModel.updateInterviewSchedule(
                date: date,
                location: location.isNotEmpty ? location : null,
              );
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('면접 일정이 저장되었습니다.'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? '저장에 실패했습니다.'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  // 날짜 파싱 헬퍼
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

  void _showNotificationSettingsDialog(
    BuildContext context,
    ApplicationDetailViewModel viewModel,
  ) {
    // 현재 마감일 알림 설정 가져오기
    NotificationSettings? currentSettings;
    if (viewModel.application.notificationSettings.deadlineNotification) {
      currentSettings = NotificationSettings(
        deadlineNotification: true,
        deadlineTiming:
            viewModel.application.notificationSettings.deadlineTiming,
        customHoursBefore:
            viewModel.application.notificationSettings.customHoursBefore,
      );
    }

    showDialog(
      context: context,
      builder: (context) => NotificationSettingsDialog(
        notificationType: 'deadline',
        initialSettings: currentSettings,
      ),
    ).then((result) async {
      if (result != null && mounted) {
        final success = await viewModel.updateNotificationSettings(
          result as NotificationSettings,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('알림 설정이 저장되었습니다.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? '알림 설정 저장에 실패했습니다.'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }
}
