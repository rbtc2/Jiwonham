// 날짜/시간 선택 필드 위젯
// 날짜 선택, 시간 포함 토글, 알림 설정을 포함한 재사용 가능한 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/notification_settings.dart';

class DateTimeField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final DateTime? selectedDate;
  final String? errorText;
  final NotificationSettings? notificationSettings;
  final Function(DateTime) onDateSelected;
  final Function(NotificationSettings?) onNotificationSettingsChanged;
  final String notificationType;
  final bool includeTime;
  final TimeOfDay? selectedTime;
  final Function(bool)? onTimeToggled;
  final Function(TimeOfDay)? onTimeSelected;
  final Function(BuildContext, String, Function(NotificationSettings?))?
      onNotificationSettingsTap;

  const DateTimeField({
    super.key,
    required this.label,
    this.icon,
    this.selectedDate,
    this.errorText,
    this.notificationSettings,
    required this.onDateSelected,
    required this.onNotificationSettingsChanged,
    required this.notificationType,
    this.includeTime = false,
    this.selectedTime,
    this.onTimeToggled,
    this.onTimeSelected,
    this.onNotificationSettingsTap,
  });

  IconData _getNotificationIcon(NotificationSettings? settings) {
    bool isEnabled = false;
    if (notificationType == 'deadline') {
      isEnabled = settings?.deadlineNotification ?? false;
    } else if (notificationType == 'announcement') {
      isEnabled = settings?.announcementNotification ?? false;
    }
    return isEnabled ? Icons.notifications : Icons.notifications_outlined;
  }

  Color _getNotificationColor(NotificationSettings? settings) {
    bool isEnabled = false;
    if (notificationType == 'deadline') {
      isEnabled = settings?.deadlineNotification ?? false;
    } else if (notificationType == 'announcement') {
      isEnabled = settings?.announcementNotification ?? false;
    }
    return isEnabled ? AppColors.primary : AppColors.textSecondary;
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time, bool includeTime) {
    if (date == null) return AppStrings.selectDate;
    if (includeTime && time != null) {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notificationColor = _getNotificationColor(notificationSettings);
    final isNotificationEnabled = notificationSettings != null &&
        ((notificationType == 'deadline' &&
                notificationSettings!.deadlineNotification) ||
            (notificationType == 'announcement' &&
                notificationSettings!.announcementNotification));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 날짜 선택 필드와 시간 포함 토글
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ko', 'KR'),
                  );
                  if (picked != null) {
                    onDateSelected(picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: errorText != null
                          ? AppColors.error
                          : Colors.grey.shade300,
                      width: errorText != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(selectedDate, selectedTime, includeTime),
                        style: TextStyle(
                          color: selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: errorText != null
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 시간 포함 토글
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '시간',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: includeTime,
                    onChanged: onTimeToggled ?? (value) {},
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 알림 설정 버튼
            if (onNotificationSettingsTap != null)
              Container(
                decoration: BoxDecoration(
                  color: isNotificationEnabled
                      ? notificationColor.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isNotificationEnabled
                        ? notificationColor
                        : Colors.grey.shade300,
                    width: isNotificationEnabled ? 1.5 : 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    onNotificationSettingsTap!(
                      context,
                      notificationType,
                      onNotificationSettingsChanged,
                    );
                  },
                  icon: Icon(
                    _getNotificationIcon(notificationSettings),
                    color: notificationColor,
                    size: 22,
                  ),
                  tooltip: '알림 설정',
                  padding: const EdgeInsets.all(12),
                ),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        // 시간 선택 필드 (토글이 켜져 있을 때만 표시)
        if (includeTime) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime:
                    selectedTime ?? const TimeOfDay(hour: 0, minute: 0),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null && onTimeSelected != null) {
                onTimeSelected!(picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedTime != null
                            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                            : '00:00',
                        style: TextStyle(
                          color: selectedTime != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

