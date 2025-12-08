// 공고 목록 화면
// 모든 공고를 목록 형태로 보여주고, 검색 및 필터 기능 제공

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';
import '../add_edit_application/add_edit_application_screen.dart';
import 'application_list_item.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => ApplicationsScreenState();
}

// Phase 3: State 클래스를 public으로 변경하여 외부에서 접근 가능하게 함
class ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  ApplicationStatus? _filterStatus;
  String _sortBy = AppStrings.sortByDeadline;

  // Phase 1: 실제 데이터 관리
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Phase 2: 검색 및 필터 상태
  String _searchQuery = '';
  String? _deadlineFilter;

  // Phase 1: 체크박스 선택 상태 관리
  bool _isSelectionMode = false;
  Set<String> _selectedApplicationIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Phase 3: 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    // Phase 1: 데이터 로드
    _loadApplications();
  }

  @override
  void dispose() {
    // Phase 3: 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  // Phase 3: 앱이 포그라운드로 돌아올 때 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 데이터 새로고침
      _loadApplications();
    }
  }

  // Phase 3: 외부에서 호출 가능한 새로고침 메서드
  void refresh() {
    if (mounted) {
      _loadApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phase 5: 검색어나 필터가 있을 때 제목에 표시
    final hasActiveFilters =
        _searchQuery.isNotEmpty ||
        _filterStatus != null ||
        _deadlineFilter != null;

    return PopScope(
      // PHASE 6: 뒤로 가기 버튼으로 선택 모드 종료
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          // 선택 모드일 때 뒤로 가기 시 선택 모드 종료
          setState(() {
            _isSelectionMode = false;
            _selectedApplicationIds.clear();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // PHASE 7: 선택 모드 진입 시 AppBar 애니메이션
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSelectionMode
                ? Text(
                    '${_selectedApplicationIds.length}개 선택됨',
                    key: const ValueKey('selection'),
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
                          _buildActiveFiltersText(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          leading: _isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // PHASE 6: 취소 버튼으로 선택 모드 종료
                    setState(() {
                      _isSelectionMode = false;
                      _selectedApplicationIds.clear();
                    });
                  },
                  tooltip: '선택 모드 종료',
                )
              : null,
          actions: _isSelectionMode
              ? [
                  // PHASE 4: 전체 선택/해제 버튼
                  Builder(
                    builder: (context) {
                      final filteredApps = _getFilteredApplications(
                        _getCurrentStatus(),
                      );
                      final isAllSelected =
                          filteredApps.isNotEmpty &&
                          _selectedApplicationIds.length == filteredApps.length;
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
                                setState(() {
                                  if (isAllSelected) {
                                    // 전체 해제
                                    _selectedApplicationIds.clear();
                                  } else {
                                    // 전체 선택
                                    _selectedApplicationIds = filteredApps
                                        .map((app) => app.id)
                                        .toSet();
                                  }
                                });
                              },
                        tooltip: isEmpty
                            ? '선택할 항목이 없습니다'
                            : (isAllSelected ? '전체 해제' : '전체 선택'),
                      );
                    },
                  ),
                  // Phase 4: 삭제 버튼
                  if (_selectedApplicationIds.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _showMultiDeleteConfirmDialog(context);
                      },
                      tooltip: '삭제',
                    ),
                ]
              : [
                  // Phase 2: 검색 아이콘 (검색어가 있을 때 배지 표시)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _showSearchDialog(context);
                        },
                        tooltip: AppStrings.search,
                      ),
                      if (_searchQuery.isNotEmpty)
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
                        onPressed: () {
                          _showFilterDialog(context);
                        },
                        tooltip: AppStrings.filter,
                      ),
                      if (_filterStatus != null || _deadlineFilter != null)
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
                    tooltip: '${AppStrings.sortBy}: ${_getSortByText(_sortBy)}',
                    onSelected: (value) {
                      setState(() {
                        _sortBy = value;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AppStrings.sortByDeadline,
                        child: Row(
                          children: [
                            Icon(
                              _sortBy == AppStrings.sortByDeadline
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: _sortBy == AppStrings.sortByDeadline
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
                              _sortBy == AppStrings.sortByDate
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: _sortBy == AppStrings.sortByDate
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
                              _sortBy == AppStrings.sortByCompany
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: _sortBy == AppStrings.sortByCompany
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildApplicationList(context, ApplicationStatus.notApplied),
            _buildApplicationList(context, ApplicationStatus.notApplied),
            _buildApplicationList(context, ApplicationStatus.inProgress),
            _buildApplicationList(context, ApplicationStatus.passed),
            _buildApplicationList(context, ApplicationStatus.rejected),
          ],
        ),
        // Phase 4: 새 공고 추가 버튼 (선택 모드일 때는 숨김)
        floatingActionButton: _isSelectionMode
            ? null
            : FloatingActionButton.extended(
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
                    refresh();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addNewApplication),
                backgroundColor: AppColors.primary,
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Phase 1: 에러 상태 표시
    if (_errorMessage != null) {
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
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadApplications();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // Phase 1: 필터링된 공고 목록 가져오기
    final filteredApplications = _getFilteredApplications(status);

    if (filteredApplications.isEmpty) {
      return _buildEmptyList(context, _getStatusText(status));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final app = filteredApplications[index];
        return ApplicationListItem(
          application: app,
          isSelectionMode: _isSelectionMode,
          isSelected: _selectedApplicationIds.contains(app.id),
          onChanged: () {
            // 상태 변경 시 목록 새로고침
            refresh();
          },
          onSelectionChanged: (isSelected) {
            setState(() {
              if (isSelected) {
                _selectedApplicationIds.add(app.id);
                // 첫 번째 선택 시 선택 모드 활성화
                if (!_isSelectionMode) {
                  _isSelectionMode = true;
                }
              } else {
                _selectedApplicationIds.remove(app.id);
                // 모든 선택 해제 시 선택 모드 비활성화
                if (_selectedApplicationIds.isEmpty) {
                  _isSelectionMode = false;
                }
              }
            });
          },
          onLongPress: () {
            // PHASE 1: 롱프레스 시 선택 모드 활성화 및 첫 항목 선택
            setState(() {
              if (!_isSelectionMode) {
                // 선택 모드 활성화
                _isSelectionMode = true;
                // 롱프레스한 항목을 첫 번째로 선택
                _selectedApplicationIds.add(app.id);
                // 햅틱 피드백
                HapticFeedback.mediumImpact();
              }
            });
          },
        );
      },
    );
  }

  // Phase 1: 필터링된 공고 목록 가져오기
  List<Application> _getFilteredApplications(ApplicationStatus status) {
    List<Application> filtered = List.from(_applications);

    // Phase 2: 검색 필터 적용
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        final query = _searchQuery.toLowerCase();
        final companyName = app.companyName.toLowerCase();
        final position = app.position?.toLowerCase() ?? '';
        return companyName.contains(query) || position.contains(query);
      }).toList();
    }

    // 탭에 따른 상태 필터링
    if (_tabController.index == 0) {
      // 전체 탭: 모든 공고 표시
    } else {
      // 각 상태별 탭: 해당 상태의 공고만 표시
      filtered = filtered.where((app) => app.status == status).toList();
    }

    // 추가 필터 적용 (필터 다이얼로그에서 설정한 필터)
    if (_filterStatus != null) {
      filtered = filtered.where((app) => app.status == _filterStatus).toList();
    }

    // Phase 2: 마감일 필터 적용
    if (_deadlineFilter != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filtered = filtered.where((app) {
        final deadline = app.deadline;
        final deadlineDate = DateTime(
          deadline.year,
          deadline.month,
          deadline.day,
        );
        final daysUntilDeadline = deadlineDate.difference(today).inDays;

        switch (_deadlineFilter) {
          case AppStrings.deadlineWithin7Days:
            return daysUntilDeadline >= 0 && daysUntilDeadline <= 7;
          case AppStrings.deadlineWithin3Days:
            return daysUntilDeadline >= 0 && daysUntilDeadline <= 3;
          case AppStrings.deadlinePassed:
            return daysUntilDeadline < 0;
          default:
            return true;
        }
      }).toList();
    }

    // 정렬 적용
    filtered = _sortApplications(filtered);

    return filtered;
  }

  // Phase 1: 공고 정렬
  List<Application> _sortApplications(List<Application> applications) {
    final sorted = List<Application>.from(applications);

    switch (_sortBy) {
      case AppStrings.sortByDeadline:
        sorted.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case AppStrings.sortByDate:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case AppStrings.sortByCompany:
        sorted.sort((a, b) => a.companyName.compareTo(b.companyName));
        break;
    }

    return sorted;
  }

  // Phase 1: 데이터 로드 메서드
  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();

      if (!mounted) return;

      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppStrings.notApplied;
      case ApplicationStatus.inProgress:
        return AppStrings.inProgress;
      case ApplicationStatus.passed:
        return AppStrings.passed;
      case ApplicationStatus.rejected:
        return AppStrings.rejected;
      default:
        return AppStrings.all;
    }
  }

  // Phase 5: 정렬 옵션 텍스트 가져오기
  String _getSortByText(String sortBy) {
    switch (sortBy) {
      case AppStrings.sortByDeadline:
        return '마감일순';
      case AppStrings.sortByDate:
        return '등록일순';
      case AppStrings.sortByCompany:
        return '회사명순';
      default:
        return '정렬';
    }
  }

  // Phase 5: 활성화된 필터 텍스트 생성
  String _buildActiveFiltersText() {
    final List<String> filters = [];

    if (_searchQuery.isNotEmpty) {
      filters.add('검색: $_searchQuery');
    }
    if (_filterStatus != null) {
      filters.add('상태: ${_getStatusText(_filterStatus!)}');
    }
    if (_deadlineFilter != null) {
      String deadlineText = '';
      switch (_deadlineFilter) {
        case AppStrings.deadlineWithin7Days:
          deadlineText = 'D-7 이내';
          break;
        case AppStrings.deadlineWithin3Days:
          deadlineText = 'D-3 이내';
          break;
        case AppStrings.deadlinePassed:
          deadlineText = '마감됨';
          break;
      }
      if (deadlineText.isNotEmpty) {
        filters.add('마감일: $deadlineText');
      }
    }

    return filters.join(' • ');
  }

  // Phase 2: 빈 목록 UI 개선
  Widget _buildEmptyList(BuildContext context, String tabName) {
    final hasFilters =
        _searchQuery.isNotEmpty ||
        _filterStatus != null ||
        _deadlineFilter != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_alt_off : Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? '필터 조건에 맞는 공고가 없습니다' : '$tabName 공고가 없습니다',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _filterStatus = null;
                  _deadlineFilter = null;
                });
              },
              child: const Text('필터 초기화'),
            ),
          ],
        ],
      ),
    );
  }

  // Phase 2: 검색 다이얼로그
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(text: _searchQuery);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.search),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.searchPlaceholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                searchController.clear();
              },
              child: const Text('초기화'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = searchController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  // Phase 2: 필터 다이얼로그
  void _showFilterDialog(BuildContext context) {
    ApplicationStatus? selectedStatus = _filterStatus;
    String? selectedDeadline = _deadlineFilter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(AppStrings.filter),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상태',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioGroup<ApplicationStatus?>(
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  },
                  child: Column(
                    children: [
                      ...ApplicationStatus.values.map((status) {
                        return RadioListTile<ApplicationStatus>(
                          title: Text(_getStatusText(status)),
                          value: status,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                      RadioListTile<ApplicationStatus?>(
                        title: const Text('전체'),
                        value: null,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '마감일',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioGroup<String?>(
                  groupValue: selectedDeadline,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDeadline = value;
                    });
                  },
                  child: Column(
                    children: [
                      RadioListTile<String?>(
                        title: const Text('전체'),
                        value: null,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String?>(
                        title: const Text(AppStrings.deadlineWithin7Days),
                        value: AppStrings.deadlineWithin7Days,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String?>(
                        title: const Text(AppStrings.deadlineWithin3Days),
                        value: AppStrings.deadlineWithin3Days,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String?>(
                        title: const Text(AppStrings.deadlinePassed),
                        value: AppStrings.deadlinePassed,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Phase 5: 필터 초기화 버튼 (필터가 적용되어 있을 때만 활성화)
            if (_filterStatus != null || _deadlineFilter != null)
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    selectedStatus = null;
                    selectedDeadline = null;
                  });
                },
                child: const Text(AppStrings.resetFilter),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterStatus = selectedStatus;
                  _deadlineFilter = selectedDeadline;
                });
                Navigator.pop(context);
              },
              child: const Text(AppStrings.applyFilter),
            ),
          ],
        ),
      ),
    );
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

  // Phase 4: 다중 삭제 확인 다이얼로그
  // PHASE 5: 다중 삭제 확인 다이얼로그
  void _showMultiDeleteConfirmDialog(BuildContext context) {
    final count = _selectedApplicationIds.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            const Expanded(child: Text(AppStrings.deleteConfirm)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '선택한 $count개의 공고를 삭제하시겠습니까?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '이 작업은 되돌릴 수 없습니다.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
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
              Navigator.pop(context);
              await _deleteSelectedApplications();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
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

    final storageService = StorageService();
    int successCount = 0;
    int failCount = 0;
    final selectedIds = List<String>.from(_selectedApplicationIds);

    for (final id in selectedIds) {
      final success = await storageService.deleteApplication(id);
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (mounted) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      setState(() {
        // PHASE 5: 삭제 후 선택 모드 자동 종료
        _isSelectionMode = false;
        _selectedApplicationIds.clear();
      });

      // 목록 새로고침
      refresh();

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
