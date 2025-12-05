// 공고 상세 화면
// 선택한 공고의 모든 정보를 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';
import '../add_edit_application/add_edit_application_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({super.key});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  // 더미 데이터
  final String _companyName = '네이버';
  final String _position = '백엔드 개발자';
  final DateTime _deadline = DateTime.now().add(const Duration(days: 5));
  final String _applicationLink = 'https://recruit.navercorp.com';
  ApplicationStatus _currentStatus = ApplicationStatus.inProgress;
  final String _memo = '면접 준비를 철저히 해야 함. 기술 질문 위주로 준비할 것.';

  // 자기소개서 문항 더미 데이터
  final List<Map<String, dynamic>> _coverLetterQuestions = [
    {
      'question': '1. 지원동기 (500자)',
      'answer': '네이버의 기술력과 서비스에 감명받아...',
      'maxLength': 500,
      'currentLength': 120,
    },
    {
      'question': '2. 입사 후 포부 (300자)',
      'answer': '',
      'maxLength': 300,
      'currentLength': 0,
    },
  ];

  // 면접 후기 더미 데이터
  final List<Map<String, dynamic>> _interviewReviews = [
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': '1차 면접',
      'questions': ['자기소개를 해주세요', '지원동기는?', '프로젝트 경험을 설명해주세요'],
      'review': '전반적으로 좋은 분위기였습니다. 기술 질문이 많았고, 팀 문화에 대해 많이 물어보셨습니다.',
      'rating': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.applicationDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditApplicationScreen(),
                ),
              );
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
                        _companyName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _position,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                DDayBadge(deadline: _deadline),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 지원서 링크 열기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('지원서 링크: $_applicationLink'),
                          action: SnackBarAction(
                            label: '열기',
                            onPressed: () {
                              // TODO: URL 열기
                            },
                          ),
                        ),
                      );
                    },
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
                    _showNotificationSettingsDialog(context);
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

  Widget _buildApplicationInfoSection(BuildContext context) {
    final announcementDate = _deadline.add(const Duration(days: 5));
    final interviewDate = _deadline.add(const Duration(days: 10));
    final finalDate = _deadline.add(const Duration(days: 15));

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
              _formatDate(_deadline),
              'D-${_deadline.difference(DateTime.now()).inDays}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.campaign,
              '서류 발표일',
              _formatDate(announcementDate),
              null,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.event,
              '다음 전형 일정',
              '면접: ${_formatDate(interviewDate)}',
              null,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.event,
              '',
              '최종: ${_formatDate(finalDate)}',
              null,
            ),
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
                Text(
                  AppStrings.coverLetterQuestions,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 문항 추가
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addQuestion),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(_coverLetterQuestions.length, (index) {
              final question = _coverLetterQuestions[index];
              final hasAnswer = (question['answer'] as String).isNotEmpty;
              return Column(
                children: [
                  _buildQuestionItem(
                    context,
                    question['question'] as String,
                    question['answer'] as String,
                    question['maxLength'] as int,
                    question['currentLength'] as int,
                    hasAnswer,
                    index,
                  ),
                  if (index < _coverLetterQuestions.length - 1)
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
                  child: Text(hasAnswer ? '수정하기' : AppStrings.write),
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
                Text(
                  AppStrings.interviewReview,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
            if (_interviewReviews.isEmpty)
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
              ...List.generate(_interviewReviews.length, (index) {
                final review = _interviewReviews[index];
                return _buildInterviewReviewItem(context, review, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewReviewItem(
    BuildContext context,
    Map<String, dynamic> review,
    int index,
  ) {
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
                    _formatDate(review['date'] as DateTime),
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
                      review['type'] as String,
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
                      i < (review['rating'] as int)
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if ((review['questions'] as List).isNotEmpty) ...[
            Text(
              AppStrings.interviewQuestions,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...(review['questions'] as List<String>).map((q) {
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
          Text(
            review['review'] as String,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
                Text(
                  AppStrings.memo,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    _showMemoDialog(context);
                  },
                  child: const Text(AppStrings.editMemo),
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
                _memo.isNotEmpty ? _memo : AppStrings.noMemo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _memo.isNotEmpty
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
            Text(
              AppStrings.changeStatus,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioGroup<ApplicationStatus>(
              groupValue: _currentStatus,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentStatus = value;
                  });
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

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.notificationSettings),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('알림 설정 기능은 추후 구현됩니다.')],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.confirm),
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
                // TODO: 저장 로직
                setState(() {
                  _coverLetterQuestions[index]['answer'] = controller.text;
                  _coverLetterQuestions[index]['currentLength'] =
                      controller.text.length;
                });
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
                // TODO: 저장 로직
                if (isEdit) {
                  setState(() {
                    _interviewReviews[index] = {
                      'date': DateTime.now(), // TODO: 실제 날짜 파싱
                      'type': typeController.text,
                      'questions': questions
                          .where((q) => q.isNotEmpty)
                          .toList(),
                      'review': reviewController.text,
                      'rating': rating,
                    };
                  });
                } else {
                  setState(() {
                    _interviewReviews.add({
                      'date': DateTime.now(), // TODO: 실제 날짜 파싱
                      'type': typeController.text,
                      'questions': questions
                          .where((q) => q.isNotEmpty)
                          .toList(),
                      'review': reviewController.text,
                      'rating': rating,
                    });
                  });
                }
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
    final controller = TextEditingController(text: _memo);
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
