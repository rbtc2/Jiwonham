// ApplicationFormData 모델
// 공고 추가/수정 폼의 모든 상태를 관리하는 클래스

import 'package:flutter/material.dart';
import 'notification_settings.dart';
import 'cover_letter_question.dart';
import 'experience_level.dart';
import 'preparation_checklist.dart';

class ApplicationFormData {
  // 컨트롤러
  final TextEditingController companyNameController;
  final TextEditingController applicationLinkController;
  final TextEditingController positionController;
  final TextEditingController workplaceController;
  final TextEditingController memoController;

  // 필수 필드
  DateTime? deadline;

  // 선택 필드
  DateTime? announcementDate;
  ExperienceLevel? experienceLevel;

  // 다음 전형 일정
  final List<Map<String, dynamic>> nextStages;

  // 지원 준비 체크리스트
  final List<PreparationChecklist> preparationChecklist;

  // 자기소개서 문항
  final List<CoverLetterQuestion> coverLetterQuestions;

  // 유효성 검사 에러 메시지
  String? companyNameError;
  String? applicationLinkError;
  String? deadlineError;

  // 알림 설정
  NotificationSettings? deadlineNotificationSettings;
  NotificationSettings? announcementNotificationSettings;

  // 시간 포함 여부 및 시간 선택
  bool deadlineIncludeTime;
  bool announcementDateIncludeTime;
  TimeOfDay? deadlineTime;
  TimeOfDay? announcementDateTime;

  // 수정 모드용 ID
  String? editingApplicationId;

  ApplicationFormData({
    TextEditingController? companyNameController,
    TextEditingController? applicationLinkController,
    TextEditingController? positionController,
    TextEditingController? workplaceController,
    TextEditingController? memoController,
    this.deadline,
    this.announcementDate,
    this.experienceLevel,
    List<PreparationChecklist>? preparationChecklist,
    List<Map<String, dynamic>>? nextStages,
    List<CoverLetterQuestion>? coverLetterQuestions,
    this.companyNameError,
    this.applicationLinkError,
    this.deadlineError,
    this.deadlineNotificationSettings,
    this.announcementNotificationSettings,
    this.deadlineIncludeTime = false,
    this.announcementDateIncludeTime = false,
    this.deadlineTime,
    this.announcementDateTime,
    this.editingApplicationId,
  })  : companyNameController =
            companyNameController ?? TextEditingController(),
        applicationLinkController =
            applicationLinkController ?? TextEditingController(),
        positionController = positionController ?? TextEditingController(),
        workplaceController = workplaceController ?? TextEditingController(),
        memoController = memoController ?? TextEditingController(),
        preparationChecklist = preparationChecklist ?? [],
        nextStages = nextStages ?? [],
        coverLetterQuestions = coverLetterQuestions ?? [];

  // 컨트롤러들 dispose
  void dispose() {
    companyNameController.dispose();
    applicationLinkController.dispose();
    positionController.dispose();
    workplaceController.dispose();
    memoController.dispose();
  }

  // copyWith 메서드
  ApplicationFormData copyWith({
    TextEditingController? companyNameController,
    TextEditingController? applicationLinkController,
    TextEditingController? positionController,
    TextEditingController? workplaceController,
    TextEditingController? memoController,
    DateTime? deadline,
    DateTime? Function()? deadlineNull,
    DateTime? announcementDate,
    DateTime? Function()? announcementDateNull,
    ExperienceLevel? experienceLevel,
    ExperienceLevel? Function()? experienceLevelNull,
    List<PreparationChecklist>? preparationChecklist,
    List<Map<String, dynamic>>? nextStages,
    List<CoverLetterQuestion>? coverLetterQuestions,
    String? companyNameError,
    String? Function()? companyNameErrorNull,
    String? applicationLinkError,
    String? Function()? applicationLinkErrorNull,
    String? deadlineError,
    String? Function()? deadlineErrorNull,
    NotificationSettings? deadlineNotificationSettings,
    NotificationSettings? Function()? deadlineNotificationSettingsNull,
    NotificationSettings? announcementNotificationSettings,
    NotificationSettings? Function()? announcementNotificationSettingsNull,
    bool? deadlineIncludeTime,
    bool? announcementDateIncludeTime,
    TimeOfDay? deadlineTime,
    TimeOfDay? Function()? deadlineTimeNull,
    TimeOfDay? announcementDateTime,
    TimeOfDay? Function()? announcementDateTimeNull,
    String? editingApplicationId,
    String? Function()? editingApplicationIdNull,
  }) {
    return ApplicationFormData(
      companyNameController: companyNameController ?? this.companyNameController,
      applicationLinkController:
          applicationLinkController ?? this.applicationLinkController,
      positionController: positionController ?? this.positionController,
      workplaceController: workplaceController ?? this.workplaceController,
      memoController: memoController ?? this.memoController,
      deadline: deadline ?? (deadlineNull != null ? null : this.deadline),
      announcementDate: announcementDate ??
          (announcementDateNull != null ? null : this.announcementDate),
      experienceLevel: experienceLevel ??
          (experienceLevelNull != null ? null : this.experienceLevel),
      preparationChecklist: preparationChecklist ?? this.preparationChecklist,
      nextStages: nextStages ?? this.nextStages,
      coverLetterQuestions:
          coverLetterQuestions ?? this.coverLetterQuestions,
      companyNameError: companyNameError ??
          (companyNameErrorNull != null ? null : this.companyNameError),
      applicationLinkError: applicationLinkError ??
          (applicationLinkErrorNull != null ? null : this.applicationLinkError),
      deadlineError: deadlineError ??
          (deadlineErrorNull != null ? null : this.deadlineError),
      deadlineNotificationSettings: deadlineNotificationSettings ??
          (deadlineNotificationSettingsNull != null
              ? null
              : this.deadlineNotificationSettings),
      announcementNotificationSettings: announcementNotificationSettings ??
          (announcementNotificationSettingsNull != null
              ? null
              : this.announcementNotificationSettings),
      deadlineIncludeTime:
          deadlineIncludeTime ?? this.deadlineIncludeTime,
      announcementDateIncludeTime:
          announcementDateIncludeTime ?? this.announcementDateIncludeTime,
      deadlineTime: deadlineTime ??
          (deadlineTimeNull != null ? null : this.deadlineTime),
      announcementDateTime: announcementDateTime ??
          (announcementDateTimeNull != null ? null : this.announcementDateTime),
      editingApplicationId: editingApplicationId ??
          (editingApplicationIdNull != null ? null : this.editingApplicationId),
    );
  }
}

