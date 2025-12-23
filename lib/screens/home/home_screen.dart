// 홈 화면
// 통계 요약, 마감 임박 공고, 오늘의 일정을 보여주는 메인 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import '../notification_settings/notification_settings_screen.dart';
import '../archive/archive_screen.dart';
import '../main_navigation.dart';
import 'widgets/statistics_section.dart';
import 'widgets/urgent_applications_section.dart';
import 'widgets/today_schedule_section.dart';
import 'widgets/error_widget.dart';
import 'home_view_model.dart';
import '../../utils/snackbar_utils.dart';

// Phase 7: ViewModel 패턴 적용
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
  String? _lastShownErrorMessage;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadApplications();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      // 에러 메시지가 있으면 SnackBar로 표시 (중복 방지)
      if (_viewModel.errorMessage != null &&
          _viewModel.errorMessage!.isNotEmpty &&
          _viewModel.errorMessage != _lastShownErrorMessage) {
        // 에러가 발생했을 때만 SnackBar 표시 (로딩 중이 아닐 때)
        if (!_viewModel.isLoading) {
          _lastShownErrorMessage = _viewModel.errorMessage;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _viewModel.errorMessage != null) {
              SnackBarUtils.showError(
                context,
                _viewModel.errorMessage!,
                duration: const Duration(seconds: 4),
              );
            }
          });
        }
      }
      // 에러가 해결되면 마지막 표시된 에러 메시지 초기화
      if (_viewModel.errorMessage == null || _viewModel.errorMessage!.isEmpty) {
        _lastShownErrorMessage = null;
      }
      setState(() {});
    }
  }

  // 새로고침 메서드 (외부에서 호출 가능)
  void refresh() {
    _viewModel.refresh();
  }

  // MainNavigation을 통해 ApplicationsScreen 새로고침
  void _refreshApplicationsScreen() {
    if (!mounted) return;
    try {
      final mainNavigationState = context
          .findAncestorStateOfType<MainNavigationState>();
      if (mainNavigationState != null) {
        mainNavigationState.refreshApplicationsScreen();
      }
    } catch (e) {
      // 에러 발생 시 무시 (이미 WidgetsBindingObserver로 자동 새로고침됨)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.work_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // 보관함 아이콘
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () async {
              // 보관함 화면으로 이동
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArchiveScreen()),
              );
              // 보관함에서 복원/삭제가 발생했을 수 있으므로 데이터 새로고침
              if (mounted) {
                _viewModel.refresh();
                _refreshApplicationsScreen();
              }
            },
            tooltip: '보관함',
          ),
          // 설정 아이콘
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              // 설정 화면으로 이동하고 결과를 받음
              final settingsChanged = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );

              // 설정이 변경되었으면 데이터 새로고침
              if (settingsChanged == true && mounted) {
                _viewModel.refresh();
              }
            },
            tooltip: AppStrings.notificationSettings,
          ),
        ],
        elevation: 0,
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.errorMessage != null && _viewModel.applications.isEmpty
          ? ErrorDisplayWidget(
              message: _viewModel.errorMessage!,
              onRetry: () {
                _viewModel.refresh();
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phase 9: 에러가 있지만 데이터가 있는 경우 경고 표시
                  if (_viewModel.errorMessage != null &&
                      _viewModel.applications.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '일부 데이터를 불러오지 못했습니다.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _viewModel.refresh();
                            },
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),

                  // Phase 7: 오늘의 통계 섹션 (ViewModel 사용)
                  StatisticsSection(
                    totalApplications: _viewModel.totalApplications,
                    inProgressCount: _viewModel.inProgressCount,
                    passedCount: _viewModel.passedCount,
                  ),
                  const SizedBox(height: 24),

                  // Phase 7: 마감 임박 공고 섹션 (ViewModel 사용)
                  UrgentApplicationsSection(
                    urgentApplications: _viewModel.urgentApplications,
                    onViewAll: () {
                      // 공고 목록 화면으로 이동
                      final mainNavigationState = context
                          .findAncestorStateOfType<MainNavigationState>();
                      if (mainNavigationState != null) {
                        mainNavigationState.setCurrentIndex(1);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Phase 7: 오늘의 일정 섹션 (ViewModel 사용)
                  TodayScheduleSection(schedules: _viewModel.todaySchedules),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Phase 3: 새 공고 추가 후 결과 확인
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditApplicationScreen(),
            ),
          );

          // Phase 7: 저장 성공 시 ApplicationsScreen 및 HomeScreen 새로고침
          if (result == true) {
            if (mounted) {
              _viewModel.refresh();
              _refreshApplicationsScreen();
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addNewApplication),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
