// CalendarViewModel
// 캘린더 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../models/application.dart';
import '../../services/storage_service.dart';

class CalendarViewModel extends ChangeNotifier {
  // 캘린더 이벤트 데이터 (날짜별로 그룹화)
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  Map<DateTime, List<Map<String, dynamic>>> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasEvents => _events.isNotEmpty;

  // Application 데이터 로드 및 이벤트 변환
  Future<void> loadApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storageService = StorageService();
      // 보관함 제외한 공고만 가져오기 (활성 공고만)
      final applications = await storageService.getActiveApplications();

      // Application 데이터를 캘린더 이벤트로 변환
      _events = _convertApplicationsToEvents(applications);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _events = {}; // 에러 발생 시 빈 맵
      notifyListeners();
    }
  }

  // Application → 캘린더 이벤트 변환
  Map<DateTime, List<Map<String, dynamic>>> _convertApplicationsToEvents(
    List<Application> applications,
  ) {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (final application in applications) {
      try {
        // 1. 서류 마감일 (deadline) 이벤트 추가
        final deadlineDate = _getDateKey(application.deadline);
        events.putIfAbsent(deadlineDate, () => []).add({
          'type': 'deadline',
          'applicationId': application.id,
          'company': application.companyName,
          'position': application.position ?? '',
        });

        // 2. 서류 발표일 (announcementDate) 이벤트 추가
        if (application.announcementDate != null) {
          final announcementDate = _getDateKey(application.announcementDate!);
          events.putIfAbsent(announcementDate, () => []).add({
            'type': 'announcement',
            'applicationId': application.id,
            'company': application.companyName,
            'position': application.position ?? '',
          });
        }

        // 3. 면접 일정 (nextStages) 이벤트 추가
        for (final stage in application.nextStages) {
          final interviewDate = _getDateKey(stage.date);
          // 시간 정보 추출 (HH:mm 형식)
          final timeString = _formatTime(stage.date);
          events.putIfAbsent(interviewDate, () => []).add({
            'type': 'interview',
            'applicationId': application.id,
            'company': application.companyName,
            'position': application.position ?? '',
            'time': timeString,
            'stageType': stage.type,
          });
        }
      } catch (e) {
        // 개별 Application 처리 중 에러 발생 시 해당 공고만 건너뛰고 계속 진행
        continue;
      }
    }

    return events;
  }

  // 날짜별 이벤트 조회 (정렬 포함)
  List<Map<String, dynamic>> getEventsForDate(DateTime date) {
    final key = _getDateKey(date);
    final events = List<Map<String, dynamic>>.from(_events[key] ?? []);

    // 이벤트 타입별 우선순위로 정렬
    // deadline(1) > announcement(2) > interview(3)
    events.sort((a, b) {
      final typeOrder = {'deadline': 1, 'announcement': 2, 'interview': 3};
      final aOrder = typeOrder[a['type']] ?? 99;
      final bOrder = typeOrder[b['type']] ?? 99;

      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }

      // 같은 타입이면 회사명으로 정렬
      final aCompany = a['company'] as String? ?? '';
      final bCompany = b['company'] as String? ?? '';
      return aCompany.compareTo(bCompany);
    });

    return events;
  }

  // 날짜 키 생성 (시간 제거, 년/월/일만 사용)
  DateTime _getDateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // 시간 포맷팅 (HH:mm)
  String _formatTime(DateTime date) {
    try {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00'; // 에러 발생 시 기본값 반환
    }
  }

  // 두 날짜가 같은 날인지 확인
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 이벤트 제목 생성 (position이 null일 때 처리)
  String getEventTitle(Map<String, dynamic> event) {
    final company = event['company'] as String? ?? '';
    final position = event['position'] as String?;

    if (position != null && position.isNotEmpty) {
      return '$company - $position';
    }
    return company;
  }
}







