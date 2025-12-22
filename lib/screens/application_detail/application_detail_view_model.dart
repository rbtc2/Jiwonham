// ApplicationDetailViewModel
// 공고 상세 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../models/cover_letter_question.dart';
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





