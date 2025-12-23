// 공고 목록 화면
// 모든 공고를 목록 형태로 보여주고, 검색 및 필터 기능 제공

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import 'applications_view_model.dart';
import 'widgets/search_query_chip.dart';
import 'widgets/applications_app_bar.dart';
import 'widgets/application_list_view.dart';
import 'applications_tab_helper.dart';

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

  // Phase 4: 검색 모드 상태는 ViewModel로 이동, TextEditingController만 유지
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ApplicationsViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _tabController = TabController(
      length: ApplicationsTabHelper.tabCount,
      vsync: this,
    );
    // Phase 5: TabController 리스너 최적화 (탭 변경 시에만 rebuild)
    _tabController.addListener(_onTabChanged);
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
    _tabController.removeListener(_onTabChanged);
    _viewModel.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Phase 5: TabController 변경 리스너 (최적화)
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // 탭 전환 중에는 rebuild하지 않음
      return;
    }
    // 탭 전환 완료 시에만 rebuild
    if (mounted) {
      setState(() {});
    }
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
    // Phase 5: 계산 로직을 별도 메서드로 분리
    final filteredApplications = _getFilteredApplications();
    final currentStatus = _getCurrentStatus();

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
        appBar: ApplicationsAppBar(
          isSelectionMode: _viewModel.isSelectionMode,
          isSearchMode: _viewModel.isSearchMode,
          searchQuery: _viewModel.searchQuery,
          sortBy: _viewModel.sortBy,
          selectedCount: _viewModel.selectedCount,
          tabController: _tabController,
          filteredApplications: filteredApplications,
          currentTabStatus: currentStatus,
          onSearchPressed: _handleSearchPressed,
          onExitSearchMode: _handleExitSearchMode,
          onExitSelectionMode: _handleExitSelectionMode,
          onClearSearchQuery: _handleClearSearchQuery,
          onSortChanged: _handleSortChanged,
          onSearchQueryChanged: _handleSearchQueryChanged,
          onSelectAll: () => _handleSelectAll(filteredApplications),
          onDeselectAll: _handleDeselectAll,
          onDeleteSelected: _handleDeleteSelected,
        ),
        body: Column(
          children: [
            // 검색어 Chip 표시 (검색 모드가 아니고 검색어가 있을 때)
            if (!_viewModel.isSearchMode && _viewModel.searchQuery.isNotEmpty)
              RepaintBoundary(
                child: SearchQueryChip(
                  query: _viewModel.searchQuery,
                  onDeleted: _handleSearchQueryChipDeleted,
                ),
              ),
            // 탭 내용
            Expanded(
              child: RepaintBoundary(
                child: TabBarView(
                  controller: _tabController,
                  children: _buildTabChildren(),
                ),
              ),
            ),
          ],
        ),
        // Phase 4: 새 공고 추가 버튼 (선택 모드일 때는 숨김)
        floatingActionButton: _viewModel.isSelectionMode
            ? null
            : RepaintBoundary(
                child: FloatingActionButton.extended(
                  onPressed: _handleAddApplication,
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addNewApplication),
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                ),
              ),
      ),
    );
  }


  // Phase 3: 리스트 빌더 로직을 별도 위젯으로 분리
  Widget _buildApplicationList(BuildContext context, ApplicationStatus status) {
    // 필터링된 공고 목록 가져오기
    final filteredApplications = _viewModel.getFilteredApplications(
      status,
      _tabController.index,
    );

    // 활성 필터 확인
    final hasActiveFilters = _viewModel.searchQuery.isNotEmpty;

    return ApplicationListView(
      isLoading: _viewModel.isLoading,
      errorMessage: _viewModel.errorMessage,
      applications: filteredApplications,
      status: status,
      isSelectionMode: _viewModel.isSelectionMode,
      selectedApplicationIds: _viewModel.selectedApplicationIds,
      hasActiveFilters: hasActiveFilters,
      statusText: _viewModel.getStatusText(status),
      onRetry: () {
        _viewModel.loadApplications();
      },
      onApplicationChanged: () {
        // 상태 변경 시 목록 새로고침
        _viewModel.loadApplications();
      },
      onSelectionToggled: (applicationId) {
        _viewModel.toggleSelection(applicationId);
      },
      onLongPress: (applicationId) {
        // 롱프레스 시 선택 모드 활성화 및 첫 항목 선택
        if (!_viewModel.isSelectionMode) {
          _viewModel.toggleSelection(applicationId);
        }
      },
      onResetFilters: () {
        _viewModel.resetFilters();
      },
    );
  }


  // Phase 2: 현재 탭의 상태 가져오기 (헬퍼 클래스 사용)
  ApplicationStatus _getCurrentStatus() {
    return ApplicationsTabHelper.getStatusForTab(_tabController.index);
  }

  // Phase 5: 필터링된 공고 목록 가져오기 (성능 최적화)
  List<Application> _getFilteredApplications() {
    return _viewModel.getFilteredApplications(
      _getCurrentStatus(),
      _tabController.index,
    );
  }

  // Phase 5: TabBarView children 생성 (캐싱 및 최적화)
  List<Widget> _buildTabChildren() {
    return ApplicationsTabHelper.getAllTabStatuses()
        .map((status) => RepaintBoundary(
              child: _buildApplicationList(context, status),
            ))
        .toList();
  }

  // Phase 5: 콜백 함수들을 메서드로 분리하여 재생성 방지
  void _handleSearchPressed() {
    _viewModel.enterSearchMode();
    // 검색 모드 진입 시 현재 검색어를 컨트롤러에 설정
    _searchController.text = _viewModel.searchQuery;
  }


  void _handleExitSearchMode() {
    _viewModel.exitSearchMode();
    // 검색 모드 종료 시 검색어가 비어있으면 컨트롤러도 초기화
    if (_viewModel.searchQuery.isEmpty) {
      _searchController.clear();
    }
  }

  void _handleExitSelectionMode() {
    _viewModel.exitSelectionMode();
  }

  void _handleClearSearchQuery() {
    _searchController.clear();
    _viewModel.setSearchQuery('');
  }

  void _handleSortChanged(String value) {
    _viewModel.setSortBy(value);
  }

  void _handleSearchQueryChanged(String value) {
    _viewModel.setSearchQuery(value);
  }

  void _handleSelectAll(List<Application> applications) {
    _viewModel.selectAll(applications);
  }

  void _handleDeselectAll() {
    _viewModel.deselectAll();
  }

  Future<void> _handleDeleteSelected() async {
    if (!mounted) return;
    await _deleteSelectedApplications();
  }

  void _handleSearchQueryChipDeleted() {
    _viewModel.setSearchQuery('');
    _searchController.clear();
  }

  // Phase 5: 새 공고 추가 처리
  Future<void> _handleAddApplication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditApplicationScreen(),
      ),
    );

    // 저장 성공 시 목록 새로고침
    if (result == true && mounted) {
      _viewModel.loadApplications();
    }
  }

  // PHASE 5: 선택된 공고 삭제
  Future<void> _deleteSelectedApplications() async {
    // PHASE 5: 삭제 중 로딩 표시
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _viewModel.deleteSelectedApplications();

    if (!mounted) return;
    // 로딩 다이얼로그 닫기
    Navigator.pop(context);

    final successCount = result['success'] as int;
    final failCount = result['fail'] as int;

    // PHASE 5: 삭제 결과 메시지 표시
    if (failCount == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$successCount개의 공고가 삭제되었습니다.',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$successCount개 삭제 성공, $failCount개 삭제 실패',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
