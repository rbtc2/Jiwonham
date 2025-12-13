// 공고 목록 화면
// 모든 공고를 목록 형태로 보여주고, 검색 및 필터 기능 제공

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application_status.dart';
import '../../widgets/dialogs/application_filter_dialog.dart';
import '../../widgets/dialogs/multi_delete_confirm_dialog.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import 'application_list_item.dart';
import 'applications_view_model.dart';
import 'widgets/application_search_bar.dart';
import 'widgets/search_query_chip.dart';
import 'widgets/empty_application_list.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => ApplicationsScreenState();
}

// Phase 3: State 클래스를 public으로 변경하여 외부에서 접근 가능하게 함
class ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late ApplicationsViewModel _viewModel;

  // UI 상태 (ViewModel에 포함되지 않는 UI 전용 상태)
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ApplicationsViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Phase 3: 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    // Phase 1: 데이터 로드
    _viewModel.loadApplications();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Phase 3: 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Phase 3: 앱이 포그라운드로 돌아올 때 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 데이터 새로고침
      _viewModel.loadApplications();
    }
  }

  // Phase 3: 외부에서 호출 가능한 새로고침 메서드
  void refresh() {
    if (mounted) {
      _viewModel.loadApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phase 5: 검색어나 필터가 있을 때 제목에 표시
    final hasActiveFilters =
        _viewModel.searchQuery.isNotEmpty ||
        _viewModel.filterStatus != null ||
        _viewModel.deadlineFilter != null;

    return PopScope(
      // PHASE 6: 뒤로 가기 버튼으로 선택 모드 종료
      canPop: !_viewModel.isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _viewModel.isSelectionMode) {
          // 선택 모드일 때 뒤로 가기 시 선택 모드 종료
          _viewModel.exitSelectionMode();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // PHASE 7: 선택 모드 진입 시 AppBar 애니메이션
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _viewModel.isSelectionMode
                ? Text(
                    '${_viewModel.selectedCount}개 선택됨',
                    key: const ValueKey('selection'),
                  )
                : _isSearchMode
                ? ApplicationSearchBar(
                    initialQuery: _viewModel.searchQuery,
                    onQueryChanged: (value) {
                      _viewModel.setSearchQuery(value);
                    },
                  )
                : Column(
                    key: const ValueKey('normal'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(AppStrings.applicationsTitle),
                      if (hasActiveFilters) ...[
                        const SizedBox(height: 2),
                        Text(
                          _viewModel.buildActiveFiltersText(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ],
                  ),
          ),
          leading: _viewModel.isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // PHASE 6: 취소 버튼으로 선택 모드 종료
                    _viewModel.exitSelectionMode();
                  },
                  tooltip: '선택 모드 종료',
                )
              : _isSearchMode
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _exitSearchMode();
                  },
                  tooltip: '검색 종료',
                )
              : null,
          actions: _viewModel.isSelectionMode
              ? [
                  // PHASE 4: 전체 선택/해제 버튼
                  Builder(
                    builder: (context) {
                      final filteredApps = _viewModel.getFilteredApplications(
                        _getCurrentStatus(),
                        _tabController.index,
                      );
                      final isAllSelected =
                          filteredApps.isNotEmpty &&
                          _viewModel.selectedCount == filteredApps.length;
                      final isEmpty = filteredApps.isEmpty;

                      return IconButton(
                        icon: Icon(
                          isAllSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        onPressed: isEmpty
                            ? null
                            : () {
                                // PHASE 4: 전체 선택/해제 시 햅틱 피드백
                                HapticFeedback.mediumImpact();
                                if (isAllSelected) {
                                  // 전체 해제
                                  _viewModel.deselectAll();
                                } else {
                                  // 전체 선택
                                  _viewModel.selectAll(filteredApps);
                                }
                              },
                        tooltip: isEmpty
                            ? '선택할 항목이 없습니다'
                            : (isAllSelected ? '전체 해제' : '전체 선택'),
                      );
                    },
                  ),
                  // Phase 4: 삭제 버튼
                  if (_viewModel.selectedCount > 0)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await MultiDeleteConfirmDialog.show(
                          context,
                          _viewModel.selectedCount,
                        );
                        if (confirmed == true) {
                          if (!mounted) return;
                          final currentContext = context;
                          if (!mounted) return;
                          await _deleteSelectedApplications(currentContext);
                        }
                      },
                      tooltip: '삭제',
                    ),
                ]
              : _isSearchMode
              ? [
                  // 검색 모드일 때는 검색어가 있으면 초기화 버튼 표시
                  if (_viewModel.searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.setSearchQuery('');
                      },
                      tooltip: '검색어 지우기',
                    ),
                ]
              : [
                  // Phase 2: 검색 아이콘 (검색어가 있을 때 배지 표시)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _enterSearchMode();
                        },
                        tooltip: AppStrings.search,
                      ),
                      if (_viewModel.searchQuery.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Phase 5: 필터 아이콘 (필터가 적용되었을 때 배지 표시)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () async {
                          final result = await ApplicationFilterDialog.show(
                            context,
                            initialStatusFilter: _viewModel.filterStatus,
                            initialDeadlineFilter: _viewModel.deadlineFilter,
                          );
                          if (result != null) {
                            _viewModel.setFilter(
                              result['status'] as ApplicationStatus?,
                              result['deadline'] as String?,
                            );
                          }
                        },
                        tooltip: AppStrings.filter,
                      ),
                      if (_viewModel.filterStatus != null ||
                          _viewModel.deadlineFilter != null)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Phase 5: 정렬 메뉴 (현재 정렬 상태 표시)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    tooltip:
                        '${AppStrings.sortBy}: ${_viewModel.getSortByText(_viewModel.sortBy)}',
                    onSelected: (value) {
                      _viewModel.setSortBy(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AppStrings.sortByDeadline,
                        child: Row(
                          children: [
                            Icon(
                              _viewModel.sortBy == AppStrings.sortByDeadline
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color:
                                  _viewModel.sortBy == AppStrings.sortByDeadline
                                  ? AppColors.primary
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text(AppStrings.sortByDeadline),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: AppStrings.sortByDate,
                        child: Row(
                          children: [
                            Icon(
                              _viewModel.sortBy == AppStrings.sortByDate
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: _viewModel.sortBy == AppStrings.sortByDate
                                  ? AppColors.primary
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text(AppStrings.sortByDate),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: AppStrings.sortByCompany,
                        child: Row(
                          children: [
                            Icon(
                              _viewModel.sortBy == AppStrings.sortByCompany
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color:
                                  _viewModel.sortBy == AppStrings.sortByCompany
                                  ? AppColors.primary
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text(AppStrings.sortByCompany),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
          bottom: _buildTabBar(context),
        ),
        body: Column(
          children: [
            // 검색어 Chip 표시 (검색 모드가 아니고 검색어가 있을 때)
            if (!_isSearchMode && _viewModel.searchQuery.isNotEmpty)
              SearchQueryChip(
                query: _viewModel.searchQuery,
                onDeleted: () {
                  _viewModel.setSearchQuery('');
                  _searchController.clear();
                },
              ),
            // 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildApplicationList(context, ApplicationStatus.notApplied),
                  _buildApplicationList(context, ApplicationStatus.notApplied),
                  _buildApplicationList(context, ApplicationStatus.inProgress),
                  _buildApplicationList(context, ApplicationStatus.passed),
                  _buildApplicationList(context, ApplicationStatus.rejected),
                ],
              ),
            ),
          ],
        ),
        // Phase 4: 새 공고 추가 버튼 (선택 모드일 때는 숨김)
        floatingActionButton: _viewModel.isSelectionMode
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  // Phase 4: 새 공고 추가 후 결과 확인
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditApplicationScreen(),
                    ),
                  );

                  // Phase 4: 저장 성공 시 목록 새로고침
                  if (result == true) {
                    _viewModel.loadApplications();
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: AppStrings.all),
        Tab(text: AppStrings.notApplied),
        Tab(text: AppStrings.inProgress),
        Tab(text: AppStrings.passed),
        Tab(text: AppStrings.rejected),
      ],
      isScrollable: false,
      tabAlignment: TabAlignment.center,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
    );
  }

  Widget _buildApplicationList(BuildContext context, ApplicationStatus status) {
    // Phase 1: 로딩 상태 표시
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Phase 1: 에러 상태 표시
    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러오는 중 오류가 발생했습니다.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _viewModel.loadApplications();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // Phase 1: 필터링된 공고 목록 가져오기
    final filteredApplications = _viewModel.getFilteredApplications(
      status,
      _tabController.index,
    );

    if (filteredApplications.isEmpty) {
      final hasFilters =
          _viewModel.searchQuery.isNotEmpty ||
          _viewModel.filterStatus != null ||
          _viewModel.deadlineFilter != null;
      return EmptyApplicationList(
        tabName: _viewModel.getStatusText(status),
        hasFilters: hasFilters,
        onResetFilters: () {
          _viewModel.resetFilters();
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final app = filteredApplications[index];
        return ApplicationListItem(
          application: app,
          isSelectionMode: _viewModel.isSelectionMode,
          isSelected: _viewModel.selectedApplicationIds.contains(app.id),
          onChanged: () {
            // 상태 변경 시 목록 새로고침
            _viewModel.loadApplications();
          },
          onSelectionChanged: (isSelected) {
            _viewModel.toggleSelection(app.id);
            if (isSelected && !_viewModel.isSelectionMode) {
              // 첫 번째 선택 시 햅틱 피드백
              HapticFeedback.mediumImpact();
            }
          },
          onLongPress: () {
            // PHASE 1: 롱프레스 시 선택 모드 활성화 및 첫 항목 선택
            if (!_viewModel.isSelectionMode) {
              _viewModel.toggleSelection(app.id);
              // 햅틱 피드백
              HapticFeedback.mediumImpact();
            }
          },
        );
      },
    );
  }

  // 검색 모드 진입
  void _enterSearchMode() {
    setState(() {
      _isSearchMode = true;
      _searchController.text = _viewModel.searchQuery;
    });
  }

  // 검색 모드 종료
  void _exitSearchMode() {
    setState(() {
      _isSearchMode = false;
      if (_viewModel.searchQuery.isEmpty) {
        _searchController.clear();
      }
    });
  }

  // Phase 1: 현재 탭의 상태 가져오기
  ApplicationStatus _getCurrentStatus() {
    switch (_tabController.index) {
      case 0:
        return ApplicationStatus.notApplied; // 전체 탭
      case 1:
        return ApplicationStatus.notApplied;
      case 2:
        return ApplicationStatus.inProgress;
      case 3:
        return ApplicationStatus.passed;
      case 4:
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.notApplied;
    }
  }

  // PHASE 5: 선택된 공고 삭제
  Future<void> _deleteSelectedApplications(BuildContext context) async {
    // PHASE 5: 삭제 중 로딩 표시
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _viewModel.deleteSelectedApplications();

    if (mounted) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      final successCount = result['success'] as int;
      final failCount = result['fail'] as int;

      // PHASE 5: 삭제 결과 메시지 표시
      if (failCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount개의 공고가 삭제되었습니다.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount개 삭제 성공, $failCount개 삭제 실패'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}
