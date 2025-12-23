// HomeStatisticsService
// 홈 화면의 통계 계산 로직을 담당하는 서비스
// - 전체 공고 수 계산
// - 진행 중 공고 수 계산
// - 합격 공고 수 계산

import '../models/application.dart';
import '../models/application_status.dart';

class HomeStatisticsService {
  // 전체 공고 수 계산
  static int getTotalApplications(List<Application> applications) {
    return applications.length;
  }

  // 진행 중 공고 수 계산
  static int getInProgressCount(List<Application> applications) {
    return applications
        .where((app) => app.status == ApplicationStatus.inProgress)
        .length;
  }

  // 합격 공고 수 계산
  static int getPassedCount(List<Application> applications) {
    return applications
        .where((app) => app.status == ApplicationStatus.passed)
        .length;
  }
}

