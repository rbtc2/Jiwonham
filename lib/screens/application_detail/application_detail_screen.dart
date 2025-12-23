// 공고 상세 화면
// 선택한 공고의 모든 정보를 보여주는 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import 'application_detail_view_model.dart';
import 'widgets/info_tab.dart';
import 'widgets/cover_letter_tab.dart';
import 'widgets/interview_review_tab.dart';

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
                  InfoTab(
                    application: viewModel.application,
                    onLinkTap: (link) => _openApplicationLink(link),
                    onMemoUpdated: (memo) async {
                      await viewModel.updateMemo(memo);
                      if (context.mounted && viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.errorMessage!),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    onStatusChanged: (status) async {
                      final error = await viewModel.updateStatus(status);
                      if (context.mounted && error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                  // 자기소개서 탭
                  CoverLetterTab(
                    application: viewModel.application,
                    onAnswerUpdated: (index, answer) async {
                      await viewModel.updateCoverLetterAnswer(index, answer);
                      if (context.mounted && viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.errorMessage!),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    onQuestionAdded: (question) async {
                      await viewModel.addCoverLetterQuestion(question);
                      if (context.mounted) {
                        if (viewModel.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('자기소개서 문항이 추가되었습니다.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  // 면접 후기 탭
                  InterviewReviewTab(
                    application: viewModel.application,
                    onReviewAdded: (review) async {
                      await viewModel.addInterviewReview(review);
                      if (context.mounted) {
                        if (viewModel.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('면접 후기가 추가되었습니다.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                    onReviewUpdated: (index, review) async {
                      await viewModel.updateInterviewReview(index, review);
                      if (context.mounted) {
                        if (viewModel.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('면접 후기가 수정되었습니다.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                    onReviewDeleted: (index) async {
                      await viewModel.deleteInterviewReview(index);
                      if (context.mounted) {
                        if (viewModel.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('면접 후기가 삭제되었습니다.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteConfirm),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 삭제 로직
              Navigator.pop(dialogContext);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('공고가 삭제되었습니다.')));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
