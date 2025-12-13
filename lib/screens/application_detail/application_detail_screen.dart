// 공고 상세 화면
// 선택한 공고의 모든 정보를 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../utils/url_utils.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import '../../widgets/dialogs/delete_application_confirm_dialog.dart';
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
  // ViewModel
  late ApplicationDetailViewModel _viewModel;
  // 탭 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = ApplicationDetailViewModel(application: widget.application);
    _viewModel.addListener(_onViewModelChanged);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // 지원서 링크 열기 (BasicInfoCard에서 사용)
  Future<void> _openApplicationLink(String link) async {
    final success = await openUrl(link);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크를 열 수 없습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 상태 변경 핸들러
  Future<void> _handleStatusChanged(ApplicationStatus newStatus) async {
    final statusText = await _viewModel.updateStatus(newStatus);
    if (mounted) {
      if (statusText != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태가 "$statusText"로 변경되었습니다.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? '상태 변경에 실패했습니다.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 변경사항이 있으면 자동으로 pop되지 않도록 함
      canPop: !_viewModel.hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        // 뒤로 가기 시 변경사항이 있으면 true 반환하여 이전 화면이 새로고침되도록 함
        if (!didPop && _viewModel.hasChanges) {
          // 변경사항이 있으면 true를 반환하여 이전 화면이 새로고침되도록 함
          // 이렇게 하면 ApplicationsScreen에서 result == true를 받아서 refresh() 호출
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
                      application: _viewModel.application,
                    ),
                  ),
                ).then((result) {
                  // 수정 완료 후 화면 새로고침 및 변경사항 플래그 설정
                  if (result == true && mounted) {
                    _viewModel.loadApplication();
                    _viewModel.markAsChanged();
                  }
                });
              },
              tooltip: AppStrings.edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final result = await DeleteApplicationConfirmDialog.show(
                  context,
                );
                if (result == true) {
                  if (!mounted) return;
                  // TODO: 삭제 로직
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('공고가 삭제되었습니다.')));
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              tooltip: AppStrings.delete,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '공고 정보'),
              Tab(text: '서류 정보'),
              Tab(text: '면접 정보'),
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
              application: _viewModel.application,
              onLinkTap: _openApplicationLink,
              onMemoUpdated: _handleMemoUpdated,
              onStatusChanged: _handleStatusChanged,
            ),
            // 자기소개서 탭
            CoverLetterTab(
              application: _viewModel.application,
              onAnswerUpdated: _handleCoverLetterAnswerUpdated,
            ),
            // 면접 후기 탭
            InterviewReviewTab(
              application: _viewModel.application,
              onReviewAdded: _handleInterviewReviewAdded,
              onReviewUpdated: _handleInterviewReviewUpdated,
              onReviewDeleted: _handleInterviewReviewDeleted,
            ),
          ],
        ),
      ),
    );
  }

  // 메모 업데이트 핸들러
  Future<void> _handleMemoUpdated(String newMemo) async {
    final success = await _viewModel.updateMemo(newMemo);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? '메모 저장에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 자기소개서 답변 업데이트 핸들러
  Future<void> _handleCoverLetterAnswerUpdated(
    int index,
    String newAnswer,
  ) async {
    final success = await _viewModel.updateCoverLetterAnswer(index, newAnswer);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? '답변 저장에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 면접 후기 추가 핸들러
  Future<void> _handleInterviewReviewAdded(InterviewReview review) async {
    final success = await _viewModel.addInterviewReview(review);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? '면접 후기 추가에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 면접 후기 업데이트 핸들러
  Future<void> _handleInterviewReviewUpdated(
    int index,
    InterviewReview review,
  ) async {
    final success = await _viewModel.updateInterviewReview(index, review);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? '면접 후기 수정에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 면접 후기 삭제 핸들러
  Future<void> _handleInterviewReviewDeleted(int index) async {
    final success = await _viewModel.deleteInterviewReview(index);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? '면접 후기 삭제에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
