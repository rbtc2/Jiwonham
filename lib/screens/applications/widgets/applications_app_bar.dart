// 공고 목록 AppBar 위젯
// 선택 모드, 검색 모드, 일반 모드를 지원하는 AppBar 위젯

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/application_status.dart';
import '../../../widgets/dialogs/application_filter_dialog.dart';
import '../../../widgets/dialogs/multi_delete_confirm_dialog.dart';
import 'application_search_bar.dart';

class ApplicationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final bool isSearchMode;
  final String searchQuery;
  final ApplicationStatus? filterStatus;
  final String? deadlineFilter;
  final String sortBy;
  final int selectedCount;
  final TabController tabController;
  final List<Application> filteredApplications;
  final ApplicationStatus currentTabStatus;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;
  final VoidCallback onExitSearchMode;
  final VoidCallback onExitSelectionMode;
  final VoidCallback onClearSearchQuery;
  final Function(String) onSortChanged;
  final Function(String) onSearchQueryChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final Future<void> Function() onDeleteSelected;

  const ApplicationsAppBar({
    super.key,
    required this.isSelectionMode,
    required this.isSearchMode,
    required this.searchQuery,
    required this.filterStatus,
    required this.deadlineFilter,
    required this.sortBy,
    required this.selectedCount,
    required this.tabController,
    required this.filteredApplications,
    required this.currentTabStatus,
    required this.onSearchPressed,
    required this.onFilterPressed,
    required this.onExitSearchMode,
    required this.onExitSelectionMode,
    required this.onClearSearchQuery,
    required this.onSortChanged,
    required this.onSearchQueryChanged,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        searchQuery.isNotEmpty || filterStatus != null || deadlineFilter != null;

    return AppBar(
      // PHASE 7: 선택 모드 진입 시 AppBar 애니메이션
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSelectionMode
            ? Text(
                '$selectedCount개 선택됨',
                key: const ValueKey('selection'),
              )
            : isSearchMode
                ? ApplicationSearchBar(
                    initialQuery: searchQuery,
                    onQueryChanged: onSearchQueryChanged,
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
      leading: isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: onExitSelectionMode,
              tooltip: '선택 모드 종료',
            )
          : isSearchMode
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onExitSearchMode,
                  tooltip: '검색 종료',
                )
              : null,
      actions: isSelectionMode
          ? [
              // PHASE 4: 전체 선택/해제 버튼
              Builder(
                builder: (context) {
                  final isAllSelected = filteredApplications.isNotEmpty &&
                      selectedCount == filteredApplications.length;
                  final isEmpty = filteredApplications.isEmpty;

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
                              onDeselectAll();
                            } else {
                              onSelectAll();
                            }
                          },
                    tooltip: isEmpty
                        ? '선택할 항목이 없습니다'
                        : (isAllSelected ? '전체 해제' : '전체 선택'),
                  );
                },
              ),
              // Phase 4: 삭제 버튼
              if (selectedCount > 0)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await MultiDeleteConfirmDialog.show(
                      context,
                      selectedCount,
                    );
                    if (confirmed == true) {
                      await onDeleteSelected();
                    }
                  },
                  tooltip: '삭제',
                ),
            ]
          : isSearchMode
              ? [
                  // 검색 모드일 때는 검색어가 있으면 초기화 버튼 표시
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSearchQuery,
                      tooltip: '검색어 지우기',
                    ),
                ]
              : [
                  // Phase 2: 검색 아이콘 (검색어가 있을 때 배지 표시)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: onSearchPressed,
                        tooltip: AppStrings.search,
                      ),
                      if (searchQuery.isNotEmpty)
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
                            initialStatusFilter: filterStatus,
                            initialDeadlineFilter: deadlineFilter,
                          );
                          if (result != null) {
                            // 필터 적용은 부모에서 처리
                            onFilterPressed();
                          }
                        },
                        tooltip: AppStrings.filter,
                      ),
                      if (filterStatus != null || deadlineFilter != null)
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
                    tooltip: '${AppStrings.sortBy}: ${_getSortByText(sortBy)}',
                    onSelected: onSortChanged,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AppStrings.sortByDeadline,
                        child: Row(
                          children: [
                            Icon(
                              sortBy == AppStrings.sortByDeadline
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: sortBy == AppStrings.sortByDeadline
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
                              sortBy == AppStrings.sortByDate
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: sortBy == AppStrings.sortByDate
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
                              sortBy == AppStrings.sortByCompany
                                  ? Icons.check
                                  : Icons.check_box_outline_blank,
                              size: 20,
                              color: sortBy == AppStrings.sortByCompany
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
      bottom: TabBar(
        controller: tabController,
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
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  String _buildActiveFiltersText() {
    final List<String> filters = [];

    if (searchQuery.isNotEmpty) {
      filters.add('검색: $searchQuery');
    }
    if (filterStatus != null) {
      filters.add('상태: ${_getStatusText(filterStatus!)}');
    }
    if (deadlineFilter != null) {
      String deadlineText = '';
      switch (deadlineFilter) {
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
}




