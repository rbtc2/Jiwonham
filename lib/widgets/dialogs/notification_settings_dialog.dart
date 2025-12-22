// 알림 설정 다이얼로그
// 알림 시점과 옵션을 설정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/notification_settings.dart';
import '../../models/notification_timing.dart';
import '../../widgets/radio_group.dart' show CustomRadioGroup;
import 'modern_bottom_sheet.dart';

class NotificationSettingsDialog {
  static Future<NotificationSettings?> show(
    BuildContext context, {
    required String notificationType,
    NotificationSettings? initialSettings,
  }) {
    bool notificationEnabled;
    NotificationTiming? selectedTiming;
    int? customHours;
    final customHoursController = TextEditingController();

    // 초기 설정
    if (notificationType == 'deadline') {
      notificationEnabled = initialSettings?.deadlineNotification ?? false;
      selectedTiming =
          initialSettings?.deadlineTiming ?? NotificationTiming.daysBefore3;
      customHours = initialSettings?.customHoursBefore ?? 24;
    } else if (notificationType == 'announcement') {
      notificationEnabled = initialSettings?.announcementNotification ?? false;
      selectedTiming =
          initialSettings?.announcementTiming ?? NotificationTiming.onTheDay;
      customHours = initialSettings?.customHoursBefore ?? 24;
    } else {
      notificationEnabled = false;
      selectedTiming = NotificationTiming.onTheDay;
      customHours = 24;
    }
    customHoursController.text = customHours.toString();

    return ModernBottomSheet.showCustom<NotificationSettings>(
      context: context,
      header: const ModernBottomSheetHeader(
        title: AppStrings.notificationSettings,
        icon: Icons.notifications_outlined,
        iconColor: AppColors.primary,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 알림 활성화 스위치
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.receiveNotification,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: notificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationEnabled = value;
                        if (!value) {
                          selectedTiming = null;
                        } else {
                          selectedTiming =
                              selectedTiming ?? NotificationTiming.onTheDay;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (notificationEnabled) ...[
                Text(
                  AppStrings.notificationTiming,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // 알림 시점 선택
                CustomRadioGroup<NotificationTiming>(
                  groupValue: selectedTiming,
                  onChanged: (value) {
                    setState(() {
                      selectedTiming = value;
                    });
                  },
                  child: Column(
                    children: [
                      ...NotificationTiming.values.map((timing) {
                        String label = _getNotificationTimingLabel(timing);
                        return RadioListTile<NotificationTiming>(
                          title: Text(label),
                          value: timing,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                    ],
                  ),
                ),
                // 사용자 지정 시간 입력
                if (selectedTiming == NotificationTiming.custom) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: customHoursController,
                    decoration: InputDecoration(
                      labelText: '알림 시간 (시간 전)',
                      hintText: '24',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hours = int.tryParse(value);
                      if (hours != null && hours > 0) {
                        setState(() {
                          customHours = hours;
                        });
                      }
                    },
                  ),
                ],
              ],
            ],
          );
        },
      ),
      actions: ModernBottomSheetActions(
        confirmText: AppStrings.save,
        onConfirm: () {
          final hours = selectedTiming == NotificationTiming.custom
              ? int.tryParse(customHoursController.text.trim()) ?? 24
              : null;

          NotificationSettings? newSettings;
          if (notificationEnabled) {
            if (notificationType == 'deadline') {
              newSettings = NotificationSettings(
                deadlineNotification: true,
                deadlineTiming: selectedTiming,
                customHoursBefore:
                    selectedTiming == NotificationTiming.custom
                    ? hours
                    : null,
              );
            } else if (notificationType == 'announcement') {
              newSettings = NotificationSettings(
                announcementNotification: true,
                announcementTiming: selectedTiming,
                customHoursBefore:
                    selectedTiming == NotificationTiming.custom
                    ? hours
                    : null,
              );
            }
          } else {
            newSettings = null;
          }

          customHoursController.dispose();
          Navigator.pop(context, newSettings);
        },
      ),
      isScrollControlled: true,
    );
  }

  static String _getNotificationTimingLabel(NotificationTiming timing) {
    switch (timing) {
      case NotificationTiming.daysBefore7:
        return 'D-7 (7일 전)';
      case NotificationTiming.daysBefore3:
        return 'D-3 (3일 전)';
      case NotificationTiming.daysBefore1:
        return 'D-1 (1일 전)';
      case NotificationTiming.onTheDay:
        return '당일';
      case NotificationTiming.custom:
        return '사용자 지정';
    }
  }
}
