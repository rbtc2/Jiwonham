// ApplicationsTabHelper
// 탭 인덱스와 ApplicationStatus 매핑을 관리하는 헬퍼 클래스

import '../../models/application_status.dart';

/// 탭 인덱스와 ApplicationStatus 매핑을 관리하는 헬퍼 클래스
class ApplicationsTabHelper {
  // 탭 개수
  static const int tabCount = 5;

  // 탭 인덱스와 ApplicationStatus 매핑
  // 인덱스 0: 전체 (notApplied로 필터링)
  // 인덱스 1: 미지원 (notApplied)
  // 인덱스 2: 진행중 (inProgress)
  // 인덱스 3: 합격 (passed)
  // 인덱스 4: 불합격 (rejected)
  static const List<ApplicationStatus> _tabStatusMap = [
    ApplicationStatus.notApplied, // 전체 탭
    ApplicationStatus.notApplied,  // 미지원 탭
    ApplicationStatus.inProgress,  // 진행중 탭
    ApplicationStatus.passed,      // 합격 탭
    ApplicationStatus.rejected,    // 불합격 탭
  ];

  /// 탭 인덱스에 해당하는 ApplicationStatus를 반환
  /// 
  /// [tabIndex] 탭 인덱스 (0-4)
  /// 
  /// Returns 해당 탭의 ApplicationStatus
  /// 유효하지 않은 인덱스인 경우 ApplicationStatus.notApplied를 반환
  static ApplicationStatus getStatusForTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < _tabStatusMap.length) {
      return _tabStatusMap[tabIndex];
    }
    return ApplicationStatus.notApplied;
  }

  /// ApplicationStatus에 해당하는 탭 인덱스를 반환
  /// 
  /// [status] 찾을 ApplicationStatus
  /// 
  /// Returns 해당 상태의 탭 인덱스, 없으면 -1
  static int getTabIndexForStatus(ApplicationStatus status) {
    return _tabStatusMap.indexOf(status);
  }

  /// 모든 탭 상태 목록을 반환
  /// 
  /// Returns 모든 탭의 ApplicationStatus 목록
  static List<ApplicationStatus> getAllTabStatuses() {
    return List.unmodifiable(_tabStatusMap);
  }
}


