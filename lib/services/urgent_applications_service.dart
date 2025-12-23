// UrgentApplicationsService
// 마감 임박 공고 필터링 및 정렬 로직을 담당하는 서비스
// - 마감 임박 공고 필터링 (D-7 이내, 마감일이 지나지 않은 공고)
// - 마감일 기준 정렬

import '../models/application.dart';

class UrgentApplicationsService {
  // 마감 임박 공고 필터링 및 정렬
  // D-7 이내이고 마감일이 지나지 않은 공고를 마감일 기준으로 정렬하여 반환
  static List<Application> getUrgentApplications(
    List<Application> applications,
  ) {
    return applications
        .where((app) => app.isUrgent && !app.isDeadlinePassed)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }
}

