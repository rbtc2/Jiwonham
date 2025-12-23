// HomeViewModel
// 홈 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../models/application.dart';
import '../../models/schedule_item.dart';
import '../../services/storage_service.dart';
import '../../services/home_statistics_service.dart';
import '../../services/urgent_applications_service.dart';
import '../../services/today_schedule_service.dart';

class HomeViewModel extends ChangeNotifier {
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 통계 계산
  int get totalApplications =>
      HomeStatisticsService.getTotalApplications(_applications);
  int get inProgressCount =>
      HomeStatisticsService.getInProgressCount(_applications);
  int get passedCount => HomeStatisticsService.getPassedCount(_applications);

  // 마감 임박 공고
  List<Application> get urgentApplications =>
      UrgentApplicationsService.getUrgentApplications(_applications);

  // 오늘의 일정
  List<ScheduleItem> get todaySchedules =>
      TodayScheduleService.getTodaySchedules(_applications);

  // 데이터 로드
  Future<void> loadApplications() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final storageService = StorageService();
      // 보관함 통계 제외 설정 확인
      final excludeArchived =
          await storageService.getExcludeArchivedFromStatistics();

      // 설정에 따라 보관함 포함/제외
      final applications = excludeArchived
          ? await storageService.getActiveApplications() // 보관함 제외
          : await storageService.getAllApplications(); // 보관함 포함

      _applications = applications;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // 에러 메시지를 사용자 친화적으로 변환
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission') || errorString.contains('권한')) {
      return '데이터 접근 권한이 없습니다. 앱 설정을 확인해주세요.';
    } else if (errorString.contains('network') || errorString.contains('인터넷')) {
      return '네트워크 연결을 확인해주세요.';
    } else if (errorString.contains('storage') || errorString.contains('저장')) {
      return '데이터 저장소에 접근할 수 없습니다.';
    } else if (errorString.contains('format') || errorString.contains('형식')) {
      return '데이터 형식이 올바르지 않습니다.';
    }
    
    return '공고를 불러오는 중 오류가 발생했습니다.\n다시 시도해주세요.';
  }

  // 새로고침
  void refresh() {
    loadApplications();
  }
}

