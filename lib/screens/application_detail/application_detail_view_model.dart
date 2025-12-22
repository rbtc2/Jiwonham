// ApplicationDetailViewModel
// 공고 상세 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../models/cover_letter_question.dart';
import '../../models/interview_question.dart';
import '../../models/interview_checklist.dart';
import '../../models/interview_schedule.dart';
import '../../models/notification_settings.dart';
import '../../services/storage_service.dart';

class ApplicationDetailViewModel extends ChangeNotifier {
  Application _application;
  bool _hasChanges = false;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicationDetailViewModel({required Application application})
      : _application = application;

  // Getters
  Application get application => _application;
  bool get hasChanges => _hasChanges;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Application 데이터 다시 로드
  Future<void> loadApplication() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();
      final updatedApplication = applications.firstWhere(
        (app) => app.id == _application.id,
        orElse: () => _application,
      );

      // 데이터가 실제로 변경되었는지 확인
      final hasDataChanged =
          _application.companyName != updatedApplication.companyName ||
          _application.position != updatedApplication.position ||
          _application.applicationLink != updatedApplication.applicationLink ||
          _application.deadline != updatedApplication.deadline ||
          _application.announcementDate != updatedApplication.announcementDate ||
          _application.memo != updatedApplication.memo;

      _application = updatedApplication;
      if (hasDataChanged) {
        _hasChanges = true;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '데이터 로드에 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 상태 텍스트 가져오기
  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppStrings.notAppliedStatus;
      case ApplicationStatus.applied:
        return AppStrings.appliedStatus;
      case ApplicationStatus.inProgress:
        return AppStrings.inProgressStatus;
      case ApplicationStatus.passed:
        return AppStrings.passedStatus;
      case ApplicationStatus.rejected:
        return AppStrings.rejectedStatus;
    }
  }

  // 상태 변경
  Future<String?> updateStatus(ApplicationStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedApplication = _application.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return _getStatusText(newStatus);
      } else {
        _isLoading = false;
        _errorMessage = '상태 변경에 실패했습니다.';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '오류가 발생했습니다: $e';
      notifyListeners();
      return null;
    }
  }

  // 메모 업데이트
  Future<bool> updateMemo(String newMemo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedApplication = _application.copyWith(
        memo: newMemo,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '메모 저장에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '메모 저장에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 자기소개서 답변 업데이트
  Future<bool> updateCoverLetterAnswer(int index, String newAnswer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final questions = List<CoverLetterQuestion>.from(
        _application.coverLetterQuestions,
      );
      questions[index] = questions[index].copyWith(answer: newAnswer);

      final updatedApplication = _application.copyWith(
        coverLetterQuestions: questions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '답변 저장에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '답변 저장에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 후기 추가
  Future<bool> addInterviewReview(InterviewReview review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reviews = List<InterviewReview>.from(_application.interviewReviews);
      reviews.add(review);

      final updatedApplication = _application.copyWith(
        interviewReviews: reviews,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 후기 추가에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 후기 추가에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 후기 업데이트
  Future<bool> updateInterviewReview(int index, InterviewReview review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reviews = List<InterviewReview>.from(_application.interviewReviews);
      reviews[index] = review;

      final updatedApplication = _application.copyWith(
        interviewReviews: reviews,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 후기 수정에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 후기 수정에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 후기 삭제
  Future<bool> deleteInterviewReview(int index) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reviews = List<InterviewReview>.from(_application.interviewReviews);
      reviews.removeAt(index);

      final updatedApplication = _application.copyWith(
        interviewReviews: reviews,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 후기 삭제에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 후기 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 질문 추가
  Future<bool> addInterviewQuestion(String question) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newQuestion = InterviewQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: question,
      );
      final updatedQuestions = [..._application.interviewQuestions, newQuestion];

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 질문 추가에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 질문 추가에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 질문 수정
  Future<bool> updateInterviewQuestion(int index, String question) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedQuestions = List<InterviewQuestion>.from(
        _application.interviewQuestions,
      );
      updatedQuestions[index] = updatedQuestions[index].copyWith(
        question: question,
      );

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 질문 수정에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 질문 수정에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 질문 삭제
  Future<bool> deleteInterviewQuestion(int index) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedQuestions = List<InterviewQuestion>.from(
        _application.interviewQuestions,
      );
      updatedQuestions.removeAt(index);

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 질문 삭제에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 질문 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 답변 업데이트
  Future<bool> updateInterviewAnswer(int index, String answer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedQuestions = List<InterviewQuestion>.from(
        _application.interviewQuestions,
      );
      updatedQuestions[index] = updatedQuestions[index].copyWith(
        answer: answer.isEmpty ? null : answer,
      );

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 답변 저장에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 답변 저장에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 체크리스트 항목 추가
  Future<bool> addChecklistItem(String item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItem = InterviewChecklist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        item: item,
      );
      final updatedChecklist = [..._application.interviewChecklist, newItem];

      final updatedApplication = _application.copyWith(
        interviewChecklist: updatedChecklist,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '체크리스트 항목 추가에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '체크리스트 항목 추가에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 체크리스트 항목 수정
  Future<bool> updateChecklistItem(int index, String item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedChecklist = List<InterviewChecklist>.from(
        _application.interviewChecklist,
      );
      updatedChecklist[index] = updatedChecklist[index].copyWith(item: item);

      final updatedApplication = _application.copyWith(
        interviewChecklist: updatedChecklist,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '체크리스트 항목 수정에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '체크리스트 항목 수정에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 체크리스트 항목 삭제
  Future<bool> deleteChecklistItem(int index) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedChecklist = List<InterviewChecklist>.from(
        _application.interviewChecklist,
      );
      updatedChecklist.removeAt(index);

      final updatedApplication = _application.copyWith(
        interviewChecklist: updatedChecklist,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '체크리스트 항목 삭제에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '체크리스트 항목 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 체크리스트 항목 토글
  Future<bool> toggleChecklistItem(int index, bool isChecked) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedChecklist = List<InterviewChecklist>.from(
        _application.interviewChecklist,
      );
      updatedChecklist[index] = updatedChecklist[index].copyWith(
        isChecked: isChecked,
      );

      final updatedApplication = _application.copyWith(
        interviewChecklist: updatedChecklist,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '체크리스트 항목 업데이트에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '체크리스트 항목 업데이트에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 면접 일정 업데이트
  Future<bool> updateInterviewSchedule({
    DateTime? date,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final schedule = InterviewSchedule(date: date, location: location);

      final updatedApplication = _application.copyWith(
        interviewSchedule: schedule,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '면접 일정 저장에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '면접 일정 저장에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 알림 설정 업데이트
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSettings = _application.notificationSettings.copyWith(
        deadlineNotification: settings.deadlineNotification,
        deadlineTiming: settings.deadlineTiming,
        customHoursBefore: settings.customHoursBefore,
      );

      final updatedApplication = _application.copyWith(
        notificationSettings: updatedSettings,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);

      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = '알림 설정 저장에 실패했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = '알림 설정 저장에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 변경사항 플래그 설정 (외부에서 호출 가능)
  void markAsChanged() {
    _hasChanges = true;
    notifyListeners();
  }

  // 변경사항 플래그 초기화
  void resetChanges() {
    _hasChanges = false;
    notifyListeners();
  }
}





