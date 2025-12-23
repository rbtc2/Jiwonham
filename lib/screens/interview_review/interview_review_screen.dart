// 면접 후기 목록 화면
// 특정 공고의 면접 후기 목록을 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'add_edit_interview_review_screen.dart';

class InterviewReviewScreen extends StatefulWidget {
  final String companyName;
  final String? position;

  const InterviewReviewScreen({
    super.key,
    required this.companyName,
    this.position,
  });

  @override
  State<InterviewReviewScreen> createState() => _InterviewReviewScreenState();
}

class _InterviewReviewScreenState extends State<InterviewReviewScreen> {
  // 더미 면접 후기 데이터
  final List<Map<String, dynamic>> _interviewReviews = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': '1차 면접',
      'questions': [
        '자기소개를 해주세요',
        '지원동기는?',
        '프로젝트 경험을 설명해주세요',
      ],
      'review': '전반적으로 좋은 분위기였습니다. 기술 질문이 많았고, 팀 문화에 대해 많이 물어보셨습니다.',
      'rating': 4,
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'type': '2차 면접',
      'questions': [
        '이전 프로젝트에서 어려웠던 점은?',
        '협업 경험에 대해 설명해주세요',
      ],
      'review': '면접관이 친절하셨고, 회사 비전에 대해 자세히 설명해주셨습니다.',
      'rating': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.interviewReview,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (widget.position != null)
              Text(
                '${widget.companyName} - ${widget.position}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              )
            else
              Text(
                widget.companyName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
          ],
        ),
      ),
      body: _interviewReviews.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _interviewReviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(context, _interviewReviews[index], index);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditInterviewReviewScreen(
                companyName: widget.companyName,
                position: widget.position,
                onSave: (reviewData) {
                  setState(() {
                    _interviewReviews.add(reviewData);
                  });
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.writeInterviewReview),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_in_talk_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noInterviewReview,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '면접 후기를 작성하여 다음 면접 준비에 활용하세요',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    Map<String, dynamic> review,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditInterviewReviewScreen(
                companyName: widget.companyName,
                position: widget.position,
                review: review,
                reviewIndex: index,
                onSave: (reviewData) {
                  setState(() {
                    _interviewReviews[index] = reviewData;
                  });
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 날짜, 유형, 평가
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
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          review['type'] as String,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < (review['rating'] as int)
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 면접 질문
              if ((review['questions'] as List).isNotEmpty) ...[
                Text(
                  AppStrings.interviewQuestions,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                ...(review['questions'] as List<String>).map((question) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: Text(
                            question,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
              // 면접 후기
              Text(
                AppStrings.interviewReviewText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                review['review'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // 액션 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditInterviewReviewScreen(
                            companyName: widget.companyName,
                            position: widget.position,
                            review: review,
                            reviewIndex: index,
                            onSave: (reviewData) {
                              setState(() {
                                _interviewReviews[index] = reviewData;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('수정'),
                  ),
                  TextButton(
                    onPressed: () {
                      _showDeleteConfirmDialog(context, index);
                    },
                    child: Text(
                      AppStrings.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int index) {
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
              setState(() {
                _interviewReviews.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('면접 후기가 삭제되었습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
