// ApplicationsViewModel
// 공고 목록 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';
import '../../services/application_filter_service.dart';

class ApplicationsViewModel extends ChangeNotifier {
  // 데이터 상태
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 필터/검색 상태
  String _searchQuery = '';
  ApplicationStatus? _filterStatus;
  String? _deadlineFilter;
  String _sortBy = AppStrings.sortByDeadline;

  // 선택 모드 상태
  bool _isSelectionMode = false;
  Set<String> _selectedApplicationIds = {};

  // Getters
  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ApplicationStatus? get filterStatus => _filterStatus;
  String? get deadlineFilter => _deadlineFilter;
  String get sortBy => _sortBy;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedApplicationIds => _selectedApplicationIds;
  int get selectedCount => _selectedApplicationIds.length;

  // 데이터 로드
  Future<void> loadApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();

      _applications = applications;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 검색 쿼리 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 필터 설정
  void setFilter(ApplicationStatus? status, String? deadline) {
    _filterStatus = status;
    _deadlineFilter = deadline;
    notifyListeners();
  }

  // 정렬 설정
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // 필터링된 공고 목록 가져오기
  List<Application> getFilteredApplications(
    ApplicationStatus tabStatus,
    int tabIndex,
  ) {
    return ApplicationFilterService.filterApplications(
      applications: _applications,
      searchQuery: _searchQuery,
      statusFilter: _filterStatus,
      tabStatus: tabStatus,
      tabIndex: tabIndex,
      deadlineFilter: _deadlineFilter,
      sortBy: _sortBy,
    );
  }

  // 공고 정렬 (호환성을 위해 유지, 내부적으로 서비스 사용)
  List<Application> sortApplications(List<Application> applications) {
    return ApplicationFilterService.sortApplications(applications, _sortBy);
  }

  // 선택 모드 관리
  void enterSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedApplicationIds.clear();
    notifyListeners();
  }

  // 항목 선택/해제
  void toggleSelection(String applicationId) {
    if (_selectedApplicationIds.contains(applicationId)) {
      _selectedApplicationIds.remove(applicationId);
      // 모든 선택 해제 시 선택 모드 비활성화
      if (_selectedApplicationIds.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedApplicationIds.add(applicationId);
      // 첫 번째 선택 시 선택 모드 활성화
      if (!_isSelectionMode) {
        _isSelectionMode = true;
      }
    }
    notifyListeners();
  }

  // 전체 선택/해제
  void selectAll(List<Application> applications) {
    _selectedApplicationIds = applications.map((app) => app.id).toSet();
    if (_selectedApplicationIds.isNotEmpty) {
      _isSelectionMode = true;
    }
    notifyListeners();
  }

  void deselectAll() {
    _selectedApplicationIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // 선택된 공고 삭제
  Future<Map<String, int>> deleteSelectedApplications() async {
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

    // 삭제 후 목록 새로고침
    await loadApplications();

    // 삭제 후 선택 모드 자동 종료
    exitSelectionMode();

    return {
      'success': successCount,
      'fail': failCount,
    };
  }

  // 필터 초기화
  void resetFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _deadlineFilter = null;
    notifyListeners();
  }

  // 상태 텍스트 가져오기 (유틸리티)
  String getStatusText(ApplicationStatus status) {
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

  // 정렬 옵션 텍스트 가져오기
  String getSortByText(String sortBy) {
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

  // 활성화된 필터 텍스트 생성
  String buildActiveFiltersText() {
    final List<String> filters = [];

    if (_searchQuery.isNotEmpty) {
      filters.add('검색: $_searchQuery');
    }
    if (_filterStatus != null) {
      filters.add('상태: ${getStatusText(_filterStatus!)}');
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
}

