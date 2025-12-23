// 필수 입력 필드 섹션 위젯
// 공고 추가/수정 화면의 필수 입력 필드들을 관리하는 섹션

import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../models/application_form_data.dart';
import '../../models/notification_settings.dart';
import '../../widgets/form_fields/labeled_text_field.dart';
import '../../widgets/form_fields/link_text_field.dart';
import '../../widgets/form_fields/date_time_field.dart';
import '../../widgets/form_fields/experience_level_field.dart';
import '../../utils/date_time_form_utils.dart';

class RequiredFieldsSection extends StatelessWidget {
  final ApplicationFormData formData;
  final Function(ApplicationFormData) onFormDataChanged;
  final Function(BuildContext, String, Function(NotificationSettings?))
      onNotificationSettingsTap;
  final Future<void> Function(String url)? onTestLink;

  const RequiredFieldsSection({
    super.key,
    required this.formData,
    required this.onFormDataChanged,
    required this.onNotificationSettingsTap,
    this.onTestLink,
  });

  // Phase 13: DateTime과 TimeOfDay 결합은 DateTimeFormUtils로 분리됨

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 회사명 입력
        LabeledTextField(
          label: AppStrings.companyNameRequired,
          controller: formData.companyNameController,
          icon: Icons.business,
          hintText: '회사명을 입력하세요',
          errorText: formData.companyNameError,
          onChanged: () {
            if (formData.companyNameError != null) {
              onFormDataChanged(
                formData.copyWith(companyNameErrorNull: () => null),
              );
            }
          },
        ),
        const SizedBox(height: 24),

        // 직무명 입력
        LabeledTextField(
          label: AppStrings.position,
          controller: formData.positionController,
          hintText: '직무명을 입력하세요',
        ),
        const SizedBox(height: 24),

        // 구분 선택
        ExperienceLevelField(
          selectedLevel: formData.experienceLevel,
          onChanged: (level) {
            onFormDataChanged(formData.copyWith(experienceLevel: level));
          },
        ),
        const SizedBox(height: 24),

        // 지원서 링크 입력
        LinkTextField(
          controller: formData.applicationLinkController,
          errorText: formData.applicationLinkError,
          onChanged: () {
            if (formData.applicationLinkError != null) {
              onFormDataChanged(
                formData.copyWith(applicationLinkErrorNull: () => null),
              );
            }
          },
          onTestLink: onTestLink,
        ),
        const SizedBox(height: 24),

        // 근무처 입력
        LabeledTextField(
          label: AppStrings.workplace,
          controller: formData.workplaceController,
          hintText: '근무처를 입력하세요',
        ),
        const SizedBox(height: 24),

        // 서류 마감일 선택
        DateTimeField(
          label: AppStrings.deadlineRequired,
          selectedDate: formData.deadline,
          errorText: formData.deadlineError,
          notificationSettings: formData.deadlineNotificationSettings,
          includeTime: formData.deadlineIncludeTime,
          selectedTime: formData.deadlineTime,
          onDateSelected: (date) {
            final newDeadline = DateTimeFormUtils.combineDateTime(
              date,
              formData.deadlineTime,
              formData.deadlineIncludeTime,
            );
            onFormDataChanged(
              formData.copyWith(
                deadline: newDeadline,
                deadlineErrorNull: () => null,
              ),
            );
          },
          onTimeToggled: (includeTime) {
            final newDeadlineTime = includeTime
                ? (formData.deadlineTime ?? const TimeOfDay(hour: 0, minute: 0))
                : null;
            final newDeadline = DateTimeFormUtils.combineDateTime(
              formData.deadline,
              newDeadlineTime,
              includeTime,
            );
            onFormDataChanged(
              formData.copyWith(
                deadlineIncludeTime: includeTime,
                deadlineTime: newDeadlineTime,
                deadline: newDeadline,
              ),
            );
          },
          onTimeSelected: (time) {
            final newDeadline = DateTimeFormUtils.combineDateTime(
              formData.deadline,
              time,
              formData.deadlineIncludeTime,
            );
            onFormDataChanged(
              formData.copyWith(
                deadlineTime: time,
                deadline: newDeadline,
              ),
            );
          },
          onNotificationSettingsChanged: (settings) {
            onFormDataChanged(
              formData.copyWith(deadlineNotificationSettings: settings),
            );
          },
          notificationType: 'deadline',
          onNotificationSettingsTap: onNotificationSettingsTap,
        ),
        const SizedBox(height: 24),

        // 서류 발표일 선택
        DateTimeField(
          label: AppStrings.announcementDate,
          selectedDate: formData.announcementDate,
          notificationSettings: formData.announcementNotificationSettings,
          includeTime: formData.announcementDateIncludeTime,
          selectedTime: formData.announcementDateTime,
          onDateSelected: (date) {
            final newAnnouncementDate = DateTimeFormUtils.combineDateTime(
              date,
              formData.announcementDateTime,
              formData.announcementDateIncludeTime,
            );
            onFormDataChanged(
              formData.copyWith(announcementDate: newAnnouncementDate),
            );
          },
          onTimeToggled: (includeTime) {
            final newAnnouncementDateTime = includeTime
                ? (formData.announcementDateTime ??
                    const TimeOfDay(hour: 0, minute: 0))
                : null;
            final newAnnouncementDate = DateTimeFormUtils.combineDateTime(
              formData.announcementDate,
              newAnnouncementDateTime,
              includeTime,
            );
            onFormDataChanged(
              formData.copyWith(
                announcementDateIncludeTime: includeTime,
                announcementDateTime: newAnnouncementDateTime,
                announcementDate: newAnnouncementDate,
              ),
            );
          },
          onTimeSelected: (time) {
            final newAnnouncementDate = DateTimeFormUtils.combineDateTime(
              formData.announcementDate,
              time,
              formData.announcementDateIncludeTime,
            );
            onFormDataChanged(
              formData.copyWith(
                announcementDateTime: time,
                announcementDate: newAnnouncementDate,
              ),
            );
          },
          onNotificationSettingsChanged: (settings) {
            onFormDataChanged(
              formData.copyWith(
                announcementNotificationSettings: settings,
              ),
            );
          },
          notificationType: 'announcement',
          onNotificationSettingsTap: onNotificationSettingsTap,
        ),
      ],
    );
  }
}

