// ApplicationDetailViewModel
// 공고 상세 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../models/cover_letter_question.dart';
import '../../services/storage_service.dart';

class ApplicationDetailViewModel extends ChangeNotifier {
  Application _application;
  bool _hasChanges = false;
  String? _errorMessage;

  ApplicationDetailViewModel({required Application application})
      : _application = application;

  // Getters
  Application get application => _application;
  bool get hasChanges => _hasChanges;
  String? get errorMessage => _errorMessage;

  // Application 다시 로드
  Future<void> loadApplication() async {
    _errorMessage = null;
    try {
      final storageService = StorageService();
      final loadedApplication =
          await storageService.getApplicationById(_application.id);
      if (loadedApplication != null) {
        _application = loadedApplication;
        _hasChanges = false;
        notifyListeners();
      } else {
        _errorMessage = '공고를 찾을 수 없습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '공고를 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 메모 업데이트
  Future<void> updateMemo(String memo) async {
    _errorMessage = null;
    try {
      final updatedApplication = _application.copyWith(
        memo: memo.isEmpty ? null : memo,
        updatedAt: DateTime.now(),
      );
      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '메모를 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '메모를 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 상태 업데이트
  Future<String?> updateStatus(ApplicationStatus status) async {
    _errorMessage = null;
    try {
      final updatedApplication = _application.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
        return null;
      } else {
        final error = '상태를 저장하는 중 오류가 발생했습니다.';
        _errorMessage = error;
        notifyListeners();
        return error;
      }
    } catch (e) {
      final error = '상태를 저장하는 중 오류가 발생했습니다: $e';
      _errorMessage = error;
      notifyListeners();
      return error;
    }
  }

  // 자기소개서 답변 업데이트
  Future<void> updateCoverLetterAnswer(int index, String answer) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.coverLetterQuestions.length) {
      _errorMessage = '유효하지 않은 문항 인덱스입니다.';
      notifyListeners();
      return;
    }

    try {
      final updatedQuestions = List<CoverLetterQuestion>.from(
        _application.coverLetterQuestions,
      );
      updatedQuestions[index] = updatedQuestions[index].copyWith(
        answer: answer.isEmpty ? null : answer,
      );

      final updatedApplication = _application.copyWith(
        coverLetterQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '답변을 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '답변을 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 후기 추가
  Future<void> addInterviewReview(InterviewReview review) async {
    _errorMessage = null;
    try {
      final updatedReviews = List<InterviewReview>.from(
        _application.interviewReviews,
      );
      updatedReviews.add(review);

      final updatedApplication = _application.copyWith(
        interviewReviews: updatedReviews,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '면접 후기를 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 후기를 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 후기 수정
  Future<void> updateInterviewReview(int index, InterviewReview review) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.interviewReviews.length) {
      _errorMessage = '유효하지 않은 면접 후기 인덱스입니다.';
      notifyListeners();
      return;
    }

    try {
      final updatedReviews = List<InterviewReview>.from(
        _application.interviewReviews,
      );
      updatedReviews[index] = review;

      final updatedApplication = _application.copyWith(
        interviewReviews: updatedReviews,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '면접 후기를 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 후기를 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 후기 삭제
  Future<void> deleteInterviewReview(int index) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.interviewReviews.length) {
      _errorMessage = '유효하지 않은 면접 후기 인덱스입니다.';
      notifyListeners();
      return;
    }

    try {
      final updatedReviews = List<InterviewReview>.from(
        _application.interviewReviews,
      );
      updatedReviews.removeAt(index);

      final updatedApplication = _application.copyWith(
        interviewReviews: updatedReviews,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '면접 후기를 삭제하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 후기를 삭제하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
}
