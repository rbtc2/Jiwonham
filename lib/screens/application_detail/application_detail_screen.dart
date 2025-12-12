// 공고 상세 화면
// 선택한 공고의 모든 정보를 보여주는 화면

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../services/storage_service.dart';
import '../add_edit_application/add_edit_application_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with SingleTickerProviderStateMixin {
  // Phase 1: 실제 Application 데이터 사용
  late Application _application;
  // 상태 변경 추적 플래그
  bool _hasChanges = false;
  // 탭 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Phase 1: Application 데이터 다시 로드
  Future<void> _loadApplication() async {
    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();
      final updatedApplication = applications.firstWhere(
        (app) => app.id == _application.id,
        orElse: () => _application,
      );

      if (mounted) {
        // Phase 2: 데이터가 실제로 변경되었는지 확인
        final hasDataChanged =
            _application.companyName != updatedApplication.companyName ||
            _application.position != updatedApplication.position ||
            _application.applicationLink !=
                updatedApplication.applicationLink ||
            _application.deadline != updatedApplication.deadline ||
            _application.announcementDate !=
                updatedApplication.announcementDate ||
            _application.memo != updatedApplication.memo;

        setState(() {
          _application = updatedApplication;
          // Phase 2: 데이터가 변경되었으면 플래그 설정
          if (hasDataChanged) {
            _hasChanges = true;
          }
        });
      }
    } catch (e) {
      // 에러 발생 시 기존 데이터 유지
    }
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

  // Phase 2: 상태 변경 메서드
  Future<void> _updateApplicationStatus(ApplicationStatus newStatus) async {
    // 상태 변경 전에 로딩 표시 (선택사항)
    final updatedApplication = _application.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    try {
      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success && mounted) {
        setState(() {
          _application = updatedApplication;
        });

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태가 "${_getStatusText(newStatus)}"로 변경되었습니다.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // 상태 변경 플래그 설정 (뒤로 가기 시 반영)
        _hasChanges = true;
      } else if (mounted) {
        // 실패 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('상태 변경에 실패했습니다.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Phase 2: 상태 텍스트 가져오기
  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppStrings.notAppliedStatus;
      case ApplicationStatus.applied:
        return AppStrings.appliedStatus;
      case ApplicationStatus.inProgress:
        return AppStrings.inProgressStatus;
      case ApplicationStatus.passed:
        return AppStrings.passedStatus;
      case ApplicationStatus.rejected:
        return AppStrings.rejectedStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Phase 3: 변경사항이 있으면 자동으로 pop되지 않도록 함
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        // Phase 3: 뒤로 가기 시 변경사항이 있으면 true 반환하여 이전 화면이 새로고침되도록 함
        if (!didPop && _hasChanges) {
          // 변경사항이 있으면 true를 반환하여 이전 화면이 새로고침되도록 함
          // 이렇게 하면 ApplicationsScreen에서 result == true를 받아서 refresh() 호출
          Navigator.of(context).pop(true);
        }
        // didPop이 true이고 _hasChanges가 true인 경우는 canPop이 false였기 때문에 발생하지 않음
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(AppStrings.applicationDetail),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Phase 1: 실제 Application 사용
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEditApplicationScreen(application: _application),
                  ),
                ).then((result) {
                  // Phase 1: 수정 완료 후 화면 새로고침 및 변경사항 플래그 설정
                  if (result == true && mounted) {
                    // Application 데이터 다시 로드
                    _loadApplication();
                    // Phase 1: 수정 완료 시 변경사항 플래그 설정
                    setState(() {
                      _hasChanges = true;
                    });
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
              Tab(text: AppStrings.coverLetterAnswers),
              Tab(text: AppStrings.interviewReview),
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
            _buildInfoTab(context),
            // 자기소개서 탭
            _buildCoverLetterTab(context),
            // 면접 후기 탭
            _buildInterviewReviewTab(context),
          ],
        ),
      ),
    );
  }

  // 정보 탭 빌드
  Widget _buildInfoTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보 카드
          _buildBasicInfoCard(context),
          const SizedBox(height: 16),

          // 지원 정보 섹션
          _buildApplicationInfoSection(context),
          const SizedBox(height: 16),

          // 메모 섹션
          _buildMemoSection(context),
          const SizedBox(height: 16),

          // 상태 변경 섹션
          _buildStatusSection(context),
          // 하단 패딩 추가 (스크롤이 끝까지 내려가도록)
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // 자기소개서 탭 빌드
  Widget _buildCoverLetterTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 자기소개서 문항 섹션
          _buildCoverLetterSection(context),
          // 하단 패딩 추가
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // 면접 후기 탭 빌드
  Widget _buildInterviewReviewTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 면접 후기 섹션
          _buildInterviewReviewSection(context),
          // 하단 패딩 추가
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
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
                        _application.companyName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (_application.position != null &&
                          _application.position!.isNotEmpty)
                        Text(
                          _application.position!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
                DDayBadge(deadline: _application.deadline),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _application.applicationLink != null
                  ? () {
                      // Phase 1: 지원서 링크 열기
                      _openApplicationLink(_application.applicationLink!);
                    }
                  : null,
              icon: const Icon(Icons.link),
              label: const Text(AppStrings.openLink),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              '서류 마감일',
              _formatDate(_application.deadline),
              'D-${_application.daysUntilDeadline}',
            ),
            if (_application.announcementDate != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                context,
                Icons.campaign,
                '서류 발표일',
                _formatDate(_application.announcementDate!),
                null,
              ),
            ],
            if (_application.nextStages.isNotEmpty) ...[
              const Divider(height: 24),
              ..._application.nextStages.map((stage) {
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

  Widget _buildCoverLetterSection(BuildContext context) {
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
            if (_application.coverLetterQuestions.isEmpty)
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
              ...List.generate(_application.coverLetterQuestions.length, (
                index,
              ) {
                final question = _application.coverLetterQuestions[index];
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
                    ),
                    if (index < _application.coverLetterQuestions.length - 1)
                      const Divider(height: 16),
                  ],
                );
              }),
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
  ) {
    return InkWell(
      onTap: () {
        _showCoverLetterDialog(context, question, answer, maxLength, index);
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
                    _showInterviewReviewDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.writeInterviewReview),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_application.interviewReviews.isEmpty)
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
              ...List.generate(_application.interviewReviews.length, (index) {
                final review = _application.interviewReviews[index];
                return _buildInterviewReviewItem(context, review, index);
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
                    review: review,
                    index: index,
                  );
                },
                child: const Text('수정'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 삭제 로직
                },
                child: Text('삭제', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
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
                    _showMemoDialog(context);
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
                _application.memo != null && _application.memo!.isNotEmpty
                    ? _application.memo!
                    : AppStrings.noMemo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      _application.memo != null && _application.memo!.isNotEmpty
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

  Widget _buildStatusSection(BuildContext context) {
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
              groupValue: _application.status,
              onChanged: (value) {
                if (value != null) {
                  // Phase 2: 상태 변경 시 저장 (다음 Phase에서 구현)
                  _updateApplicationStatus(value);
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
              onPressed: () {
                // TODO: Phase 2에서 저장 로직 구현
                // setState(() {
                //   _application.coverLetterQuestions[index] = ...
                // });
                Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showInterviewReviewDialog(
    BuildContext context, {
    Map<String, dynamic>? review,
    int? index,
  }) {
    final isEdit = review != null && index != null;
    final dateController = TextEditingController(
      text: isEdit ? _formatDate(review['date'] as DateTime) : '',
    );
    final typeController = TextEditingController(
      text: isEdit ? review['type'] as String : '',
    );
    final reviewController = TextEditingController(
      text: isEdit ? review['review'] as String : '',
    );
    int rating = isEdit ? review['rating'] as int : 3;
    final List<String> questions = isEdit
        ? List<String>.from(review['questions'] as List)
        : [];

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
              onPressed: () {
                // TODO: Phase 2에서 저장 로직 구현
                // if (isEdit) {
                //   setState(() {
                //     _application.interviewReviews[index] = ...
                //   });
                // } else {
                //   setState(() {
                //     _application.interviewReviews.add(...);
                //   });
                // }
                Navigator.pop(context);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemoDialog(BuildContext context) {
    final controller = TextEditingController(text: _application.memo ?? '');
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
            onPressed: () {
              // TODO: 저장 로직
              setState(() {
                // _memo = controller.text; // 실제로는 상태 관리 필요
              });
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
