// 공고 목록 화면
// 모든 공고를 목록 형태로 보여주고, 검색 및 필터 기능 제공

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/status_chip.dart';
import 'application_list_item.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  ApplicationStatus? _filterStatus;
  String _sortBy = AppStrings.sortByDeadline;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.applicationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
            tooltip: AppStrings.search,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
            tooltip: AppStrings.filter,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
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
      isScrollable: true,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
    );
  }

  Widget _buildApplicationList(BuildContext context, ApplicationStatus status) {
    // TODO: 실제 데이터로 교체
    final dummyApplications = _getDummyApplications(status);

    if (dummyApplications.isEmpty) {
      return _buildEmptyList(context, _getStatusText(status));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: dummyApplications.length,
      itemBuilder: (context, index) {
        final app = dummyApplications[index];
        return ApplicationListItem(
          companyName: app['companyName'] as String,
          position: app['position'] as String?,
          deadline: app['deadline'] as DateTime,
          status: app['status'] as ApplicationStatus,
          isApplied: app['isApplied'] as bool,
          interviewDate: app['interviewDate'] as DateTime?,
        );
      },
    );
  }

  List<Map<String, dynamic>> _getDummyApplications(ApplicationStatus status) {
    final now = DateTime.now();
    final applications = <Map<String, dynamic>>[];

    // 전체 탭에는 모든 상태의 공고 표시
    if (_tabController.index == 0) {
      applications.addAll([
        {
          'companyName': '네이버',
          'position': '백엔드 개발자',
          'deadline': now.add(const Duration(days: 2)),
          'status': ApplicationStatus.notApplied,
          'isApplied': false,
          'interviewDate': null,
        },
        {
          'companyName': '카카오',
          'position': '프론트엔드 개발자',
          'deadline': now.add(const Duration(days: 5)),
          'status': ApplicationStatus.inProgress,
          'isApplied': true,
          'interviewDate': now.add(const Duration(days: 10)),
        },
        {
          'companyName': '삼성전자',
          'position': '소프트웨어 엔지니어',
          'deadline': now.add(const Duration(days: 7)),
          'status': ApplicationStatus.passed,
          'isApplied': true,
          'interviewDate': null,
        },
      ]);
    } else {
      // 각 상태별 탭에는 해당 상태의 공고만 표시
      if (status == ApplicationStatus.notApplied && _tabController.index == 1) {
        applications.add({
          'companyName': '네이버',
          'position': '백엔드 개발자',
          'deadline': now.add(const Duration(days: 2)),
          'status': ApplicationStatus.notApplied,
          'isApplied': false,
          'interviewDate': null,
        });
      } else if (status == ApplicationStatus.inProgress &&
          _tabController.index == 2) {
        applications.add({
          'companyName': '카카오',
          'position': '프론트엔드 개발자',
          'deadline': now.add(const Duration(days: 5)),
          'status': ApplicationStatus.inProgress,
          'isApplied': true,
          'interviewDate': now.add(const Duration(days: 10)),
        });
      } else if (status == ApplicationStatus.passed &&
          _tabController.index == 3) {
        applications.add({
          'companyName': '삼성전자',
          'position': '소프트웨어 엔지니어',
          'deadline': now.add(const Duration(days: 7)),
          'status': ApplicationStatus.passed,
          'isApplied': true,
          'interviewDate': null,
        });
      }
    }

    return applications;
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

  Widget _buildEmptyList(BuildContext context, String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '$tabName 공고가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.search),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.searchPlaceholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            _searchQuery = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    ApplicationStatus? selectedStatus = _filterStatus;
    String? selectedDeadline;

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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...ApplicationStatus.values.map((status) {
                  return RadioListTile<ApplicationStatus>(
                    title: Text(_getStatusText(status)),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                RadioListTile<ApplicationStatus?>(
                  title: const Text('전체'),
                  value: null,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Text(
                  '마감일',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String?>(
                  title: const Text('전체'),
                  value: null,
                  groupValue: selectedDeadline,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDeadline = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String?>(
                  title: const Text(AppStrings.deadlineWithin7Days),
                  value: AppStrings.deadlineWithin7Days,
                  groupValue: selectedDeadline,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDeadline = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String?>(
                  title: const Text(AppStrings.deadlineWithin3Days),
                  value: AppStrings.deadlineWithin3Days,
                  groupValue: selectedDeadline,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDeadline = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String?>(
                  title: const Text(AppStrings.deadlinePassed),
                  value: AppStrings.deadlinePassed,
                  groupValue: selectedDeadline,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDeadline = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
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
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterStatus = selectedStatus;
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
