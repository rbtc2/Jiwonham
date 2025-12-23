// FormDataUpdater
// ApplicationFormData 업데이트를 위한 헬퍼 유틸리티

import '../../models/application_form_data.dart';
import '../../models/preparation_checklist.dart';
import '../../models/cover_letter_question.dart';

class FormDataUpdater {
  // 체크리스트 항목 추가
  static ApplicationFormData addChecklistItem(
    ApplicationFormData formData,
    String itemText,
  ) {
    final updatedChecklist = List<PreparationChecklist>.from(
      formData.preparationChecklist,
    );
    updatedChecklist.add(
      PreparationChecklist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        item: itemText,
        isChecked: false,
      ),
    );
    return formData.copyWith(preparationChecklist: updatedChecklist);
  }

  // 체크리스트 항목 수정
  static ApplicationFormData updateChecklistItem(
    ApplicationFormData formData,
    int index,
    String itemText,
  ) {
    final updatedChecklist = List<PreparationChecklist>.from(
      formData.preparationChecklist,
    );
    updatedChecklist[index] = updatedChecklist[index].copyWith(
      item: itemText,
    );
    return formData.copyWith(preparationChecklist: updatedChecklist);
  }

  // 체크리스트 항목 삭제
  static ApplicationFormData removeChecklistItem(
    ApplicationFormData formData,
    int index,
  ) {
    final updatedChecklist = List<PreparationChecklist>.from(
      formData.preparationChecklist,
    );
    updatedChecklist.removeAt(index);
    return formData.copyWith(preparationChecklist: updatedChecklist);
  }

  // 일정 추가
  static ApplicationFormData addStage(
    ApplicationFormData formData,
    String type,
    DateTime date,
  ) {
    final updatedStages = List<Map<String, dynamic>>.from(
      formData.nextStages,
    );
    updatedStages.add({
      'type': type,
      'date': date,
    });
    return formData.copyWith(nextStages: updatedStages);
  }

  // 일정 수정
  static ApplicationFormData updateStage(
    ApplicationFormData formData,
    int index,
    String type,
    DateTime date,
  ) {
    final updatedStages = List<Map<String, dynamic>>.from(
      formData.nextStages,
    );
    updatedStages[index] = {
      'type': type,
      'date': date,
    };
    return formData.copyWith(nextStages: updatedStages);
  }

  // 일정 삭제
  static ApplicationFormData removeStage(
    ApplicationFormData formData,
    int index,
  ) {
    final updatedStages = List<Map<String, dynamic>>.from(
      formData.nextStages,
    );
    updatedStages.removeAt(index);
    return formData.copyWith(nextStages: updatedStages);
  }

  // 문항 추가
  static ApplicationFormData addQuestion(
    ApplicationFormData formData,
    String question,
    int maxLength,
  ) {
    final updatedQuestions = List<CoverLetterQuestion>.from(
      formData.coverLetterQuestions,
    );
    updatedQuestions.add(
      CoverLetterQuestion(
        question: question,
        maxLength: maxLength,
      ),
    );
    return formData.copyWith(coverLetterQuestions: updatedQuestions);
  }

  // 문항 수정
  static ApplicationFormData updateQuestion(
    ApplicationFormData formData,
    int index,
    String question,
    int maxLength,
  ) {
    final updatedQuestions = List<CoverLetterQuestion>.from(
      formData.coverLetterQuestions,
    );
    final existingQuestion = updatedQuestions[index];
    updatedQuestions[index] = CoverLetterQuestion(
      question: question,
      maxLength: maxLength,
      answer: existingQuestion.answer,
    );
    return formData.copyWith(coverLetterQuestions: updatedQuestions);
  }

  // 문항 삭제
  static ApplicationFormData removeQuestion(
    ApplicationFormData formData,
    int index,
  ) {
    final updatedQuestions = List<CoverLetterQuestion>.from(
      formData.coverLetterQuestions,
    );
    updatedQuestions.removeAt(index);
    return formData.copyWith(coverLetterQuestions: updatedQuestions);
  }
}

