// ApplicationDetailViewModel
// 공고 상세 화면의 비즈니스 로직과 상태 관리를 담당하는 ViewModel

import 'package:flutter/foundation.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/interview_review.dart';
import '../../models/interview_question.dart';
import '../../models/cover_letter_question.dart';
import '../../models/preparation_checklist.dart';
import '../../services/storage_service.dart';

class ApplicationDetailViewModel extends ChangeNotifier {
  Application _application;
  bool _hasChanges = false;
  String? _errorMessage;
  bool _isLoading = false;

  ApplicationDetailViewModel({required Application application})
      : _application = application {
    // 생성 시 최신 데이터 자동 로드
    loadApplication();
  }

  // Getters
  Application get application => _application;
  bool get hasChanges => _hasChanges;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Application 다시 로드
  Future<void> loadApplication() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final storageService = StorageService();
      final loadedApplication =
          await storageService.getApplicationById(_application.id);
      if (loadedApplication != null) {
        _application = loadedApplication;
        _hasChanges = false;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = '공고를 찾을 수 없습니다.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '공고를 불러오는 중 오류가 발생했습니다: $e';
      _isLoading = false;
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

  // 자기소개서 문항 추가
  Future<void> addCoverLetterQuestion(CoverLetterQuestion question) async {
    _errorMessage = null;
    try {
      final updatedQuestions = List<CoverLetterQuestion>.from(
        _application.coverLetterQuestions,
      );
      updatedQuestions.add(question);

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
        _errorMessage = '자기소개서 문항을 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '자기소개서 문항을 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 예상 질문 추가
  Future<void> addInterviewQuestion(InterviewQuestion question) async {
    _errorMessage = null;
    try {
      final updatedQuestions = List<InterviewQuestion>.from(
        _application.interviewQuestions,
      );
      updatedQuestions.add(question);

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '면접 예상 질문을 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 예상 질문을 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 예상 질문 수정
  Future<void> updateInterviewQuestion(
    int index,
    InterviewQuestion question,
  ) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.interviewQuestions.length) {
      _errorMessage = '유효하지 않은 면접 예상 질문 인덱스입니다.';
      notifyListeners();
      return;
    }

    try {
      final updatedQuestions = List<InterviewQuestion>.from(
        _application.interviewQuestions,
      );
      updatedQuestions[index] = question;

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '면접 예상 질문을 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 예상 질문을 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 예상 질문 답변 업데이트
  Future<void> updateInterviewAnswer(
    int index,
    InterviewQuestion question,
  ) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.interviewQuestions.length) {
      _errorMessage = '유효하지 않은 면접 예상 질문 인덱스입니다.';
      notifyListeners();
      return;
    }

    try {
      final updatedQuestions = List<InterviewQuestion>.from(
        _application.interviewQuestions,
      );
      updatedQuestions[index] = question;

      final updatedApplication = _application.copyWith(
        interviewQuestions: updatedQuestions,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '면접 예상 질문 답변을 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 예상 질문 답변을 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 면접 예상 질문 삭제
  Future<void> deleteInterviewQuestion(int index) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.interviewQuestions.length) {
      _errorMessage = '유효하지 않은 면접 예상 질문 인덱스입니다.';
      notifyListeners();
      return;
    }

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
        notifyListeners();
      } else {
        _errorMessage = '면접 예상 질문을 삭제하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '면접 예상 질문을 삭제하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 지원 준비 체크리스트 토글
  Future<void> togglePreparationChecklist(int index) async {
    _errorMessage = null;
    if (index < 0 || index >= _application.preparationChecklist.length) {
      _errorMessage = '유효하지 않은 체크리스트 인덱스입니다.';
      notifyListeners();
      return;
    }

    try {
      final updatedChecklist = List<PreparationChecklist>.from(
        _application.preparationChecklist,
      );
      updatedChecklist[index] = updatedChecklist[index].copyWith(
        isChecked: !updatedChecklist[index].isChecked,
      );

      final updatedApplication = _application.copyWith(
        preparationChecklist: updatedChecklist,
        updatedAt: DateTime.now(),
      );

      final storageService = StorageService();
      final success = await storageService.saveApplication(updatedApplication);
      if (success) {
        _application = updatedApplication;
        _hasChanges = true;
        notifyListeners();
      } else {
        _errorMessage = '체크리스트를 저장하는 중 오류가 발생했습니다.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '체크리스트를 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  // 공고 삭제
  Future<bool> deleteApplication() async {
    _errorMessage = null;
    try {
      final storageService = StorageService();
      final success = await storageService.deleteApplication(_application.id);
      if (success) {
        return true;
      } else {
        _errorMessage = '공고를 삭제하는 중 오류가 발생했습니다.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '공고를 삭제하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }
}
