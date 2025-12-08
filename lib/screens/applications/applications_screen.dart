// 공고 목록 화면
// 모든 공고를 목록 형태로 보여주고, 검색 및 필터 기능 제공

import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
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
        actions: [
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
      // Phase 4: 새 공고 추가 버튼
      floatingActionButton: FloatingActionButton.extended(
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
        // Phase 1: 다음 전형 일정에서 면접 날짜 찾기
        DateTime? interviewDate;
        for (final stage in app.nextStages) {
          if (stage.type.toLowerCase().contains('면접') ||
              stage.type.toLowerCase().contains('interview')) {
            interviewDate = stage.date;
            break;
          }
        }
        return ApplicationListItem(
          companyName: app.companyName,
          position: app.position,
          deadline: app.deadline,
          status: app.status,
          isApplied: app.isApplied,
          interviewDate: interviewDate,
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
}
