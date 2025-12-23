// ApplicationFormConverter 서비스
// Application과 ApplicationFormData 간의 변환 로직을 담당하는 서비스

import 'package:flutter/material.dart';
import '../models/application.dart';
import '../models/application_form_data.dart';
import '../models/next_stage.dart';
import '../models/notification_settings.dart';
import '../models/application_status.dart';

class ApplicationFormConverter {
  // Application을 ApplicationFormData로 변환
  static ApplicationFormData fromApplication(Application application) {
    // 시간 정보 추출
    bool deadlineIncludeTime = false;
    TimeOfDay? deadlineTime;
    if (application.deadline.hour != 0 || application.deadline.minute != 0) {
      deadlineIncludeTime = true;
      deadlineTime = TimeOfDay(
        hour: application.deadline.hour,
        minute: application.deadline.minute,
      );
    }

    bool announcementDateIncludeTime = false;
    TimeOfDay? announcementDateTime;
    if (application.announcementDate != null) {
      final announcementHour = application.announcementDate!.hour;
      final announcementMinute = application.announcementDate!.minute;
      if (announcementHour != 0 || announcementMinute != 0) {
        announcementDateIncludeTime = true;
        announcementDateTime = TimeOfDay(
          hour: announcementHour,
          minute: announcementMinute,
        );
      }
    }

    // NextStage 리스트 변환
    final List<Map<String, dynamic>> nextStages = application.nextStages
        .map((stage) => {'type': stage.type, 'date': stage.date})
        .toList();

    // 알림 설정 추출
    final notificationSettings = application.notificationSettings;
    NotificationSettings? deadlineNotificationSettings;
    if (notificationSettings.deadlineNotification) {
      deadlineNotificationSettings = NotificationSettings(
        deadlineNotification: true,
        deadlineTiming: notificationSettings.deadlineTiming,
        customHoursBefore: notificationSettings.customHoursBefore,
      );
    }
    NotificationSettings? announcementNotificationSettings;
    if (notificationSettings.announcementNotification) {
      announcementNotificationSettings = NotificationSettings(
        announcementNotification: true,
        announcementTiming: notificationSettings.announcementTiming,
      );
    }

    // ApplicationFormData 생성
    return ApplicationFormData(
      companyNameController: TextEditingController(
        text: application.companyName,
      ),
      applicationLinkController: TextEditingController(
        text: application.applicationLink ?? '',
      ),
      positionController: TextEditingController(
        text: application.position ?? '',
      ),
      workplaceController: TextEditingController(
        text: application.workplace ?? '',
      ),
      memoController: TextEditingController(text: application.memo ?? ''),
      deadline: application.deadline,
      announcementDate: application.announcementDate,
      experienceLevel: application.experienceLevel,
      preparationChecklist: List.from(application.preparationChecklist),
      nextStages: nextStages,
      coverLetterQuestions: List.from(application.coverLetterQuestions),
      deadlineIncludeTime: deadlineIncludeTime,
      deadlineTime: deadlineTime,
      announcementDateIncludeTime: announcementDateIncludeTime,
      announcementDateTime: announcementDateTime,
      deadlineNotificationSettings: deadlineNotificationSettings,
      announcementNotificationSettings: announcementNotificationSettings,
      editingApplicationId: application.id,
    );
  }

  // ApplicationFormData를 Application으로 변환
  static Application toApplication(
    ApplicationFormData formData, {
    Application? existingApplication,
  }) {
    // NextStage 리스트 변환
    final List<NextStage> nextStages = formData.nextStages.map((stage) {
      return NextStage(
        type: stage['type'] as String,
        date: stage['date'] as DateTime,
      );
    }).toList();

    // 알림 설정 통합
    NotificationSettings notificationSettings = NotificationSettings();
    if (formData.deadlineNotificationSettings != null) {
      notificationSettings = notificationSettings.copyWith(
        deadlineNotification:
            formData.deadlineNotificationSettings!.deadlineNotification,
        deadlineTiming:
            formData.deadlineNotificationSettings!.deadlineTiming,
        customHoursBefore:
            formData.deadlineNotificationSettings!.customHoursBefore,
      );
    }
    if (formData.announcementNotificationSettings != null) {
      notificationSettings = notificationSettings.copyWith(
        announcementNotification: formData
            .announcementNotificationSettings!
            .announcementNotification,
        announcementTiming:
            formData.announcementNotificationSettings!.announcementTiming,
      );
    }

    // 지원서 링크 처리 - 스킴이 없으면 자동으로 https:// 추가
    String? applicationLink =
        formData.applicationLinkController.text.trim();
    if (applicationLink.isNotEmpty) {
      if (!applicationLink.contains(
        RegExp(r'^https?://', caseSensitive: false),
      )) {
        applicationLink = 'https://$applicationLink';
      }
    }

    // Application 객체 생성
    final now = DateTime.now();
    return Application(
      id: formData.editingApplicationId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: formData.companyNameController.text.trim(),
      position: formData.positionController.text.trim().isEmpty
          ? null
          : formData.positionController.text.trim(),
      experienceLevel: formData.experienceLevel,
      applicationLink: applicationLink.isEmpty ? null : applicationLink,
      workplace: formData.workplaceController.text.trim().isEmpty
          ? null
          : formData.workplaceController.text.trim(),
      deadline: formData.deadline!,
      announcementDate: formData.announcementDate,
      preparationChecklist: formData.preparationChecklist,
      nextStages: nextStages,
      coverLetterQuestions: formData.coverLetterQuestions,
      memo: formData.memoController.text.trim().isEmpty
          ? null
          : formData.memoController.text.trim(),
      status: existingApplication?.status ?? ApplicationStatus.notApplied,
      isApplied: existingApplication?.isApplied ?? false,
      notificationSettings: notificationSettings,
      createdAt: existingApplication?.createdAt ?? now,
      updatedAt: now,
    );
  }
}

