// ApplicationFilterService
// 공고 필터링 및 정렬 로직을 담당하는 서비스 클래스

import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';

class ApplicationFilterService {
  // 필터링된 공고 목록 가져오기
  static List<Application> filterApplications({
    required List<Application> applications,
    String? searchQuery,
    ApplicationStatus? statusFilter,
    ApplicationStatus? tabStatus,
    int? tabIndex,
    String? deadlineFilter,
    String sortBy = AppStrings.sortByDeadline,
  }) {
    List<Application> filtered = List.from(applications);

    // 검색 필터 적용
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        final query = searchQuery.toLowerCase();
        final companyName = app.companyName.toLowerCase();
        final position = app.position?.toLowerCase() ?? '';
        return companyName.contains(query) || position.contains(query);
      }).toList();
    }

    // 탭에 따른 상태 필터링
    if (tabIndex != null) {
      if (tabIndex == 0) {
        // 전체 탭: 모든 공고 표시
      } else if (tabStatus != null) {
        // 각 상태별 탭: 해당 상태의 공고만 표시
        filtered = filtered.where((app) => app.status == tabStatus).toList();
      }
    }

    // 추가 필터 적용 (필터 다이얼로그에서 설정한 필터)
    if (statusFilter != null) {
      filtered = filtered.where((app) => app.status == statusFilter).toList();
    }

    // 마감일 필터 적용
    if (deadlineFilter != null) {
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

        switch (deadlineFilter) {
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
    filtered = sortApplications(filtered, sortBy);

    return filtered;
  }

  // 공고 정렬
  static List<Application> sortApplications(
    List<Application> applications,
    String sortBy,
  ) {
    final sorted = List<Application>.from(applications);

    switch (sortBy) {
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
}




