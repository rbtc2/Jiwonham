// 알림 설정 다이얼로그
// 알림 시점과 옵션을 설정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../models/notification_settings.dart';
import '../../models/notification_timing.dart';
import '../../widgets/radio_group.dart' show CustomRadioGroup;

class NotificationSettingsDialog extends StatefulWidget {
  final String notificationType;
  final NotificationSettings? initialSettings;

  const NotificationSettingsDialog({
    super.key,
    required this.notificationType,
    this.initialSettings,
  });

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  late bool _notificationEnabled;
  late NotificationTiming? _selectedTiming;
  late int? _customHours;
  final TextEditingController _customHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    if (widget.notificationType == 'deadline') {
      _notificationEnabled =
          widget.initialSettings?.deadlineNotification ?? false;
      _selectedTiming =
          widget.initialSettings?.deadlineTiming ?? NotificationTiming.daysBefore3;
      _customHours = widget.initialSettings?.customHoursBefore ?? 24;
    } else if (widget.notificationType == 'announcement') {
      _notificationEnabled =
          widget.initialSettings?.announcementNotification ?? false;
      _selectedTiming =
          widget.initialSettings?.announcementTiming ?? NotificationTiming.onTheDay;
      _customHours = widget.initialSettings?.customHoursBefore ?? 24;
    } else {
      _notificationEnabled = false;
      _selectedTiming = NotificationTiming.onTheDay;
      _customHours = 24;
    }
    _customHoursController.text = _customHours.toString();
  }

  @override
  void dispose() {
    _customHoursController.dispose();
    super.dispose();
  }

  String _getNotificationTimingLabel(NotificationTiming timing) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.notificationSettings),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 활성화 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.receiveNotification,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationEnabled = value;
                      if (!value) {
                        _selectedTiming = null;
                      } else {
                        _selectedTiming =
                            _selectedTiming ?? NotificationTiming.onTheDay;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_notificationEnabled) ...[
              const Text(
                AppStrings.notificationTiming,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 알림 시점 선택
              CustomRadioGroup<NotificationTiming>(
                groupValue: _selectedTiming,
                onChanged: (value) {
                  setState(() {
                    _selectedTiming = value;
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
                        groupValue: _selectedTiming,
                        onChanged: (value) {
                          setState(() {
                            _selectedTiming = value;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              // 사용자 지정 시간 입력
              if (_selectedTiming == NotificationTiming.custom) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _customHoursController,
                  decoration: InputDecoration(
                    labelText: '알림 시간 (시간 전)',
                    hintText: '24',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final hours = int.tryParse(value);
                    if (hours != null && hours > 0) {
                      setState(() {
                        _customHours = hours;
                      });
                    }
                  },
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final hours = _selectedTiming == NotificationTiming.custom
                ? int.tryParse(_customHoursController.text.trim()) ?? 24
                : null;

            NotificationSettings? newSettings;
            if (_notificationEnabled) {
              if (widget.notificationType == 'deadline') {
                newSettings = NotificationSettings(
                  deadlineNotification: true,
                  deadlineTiming: _selectedTiming,
                  customHoursBefore:
                      _selectedTiming == NotificationTiming.custom
                      ? hours
                      : null,
                );
              } else if (widget.notificationType == 'announcement') {
                newSettings = NotificationSettings(
                  announcementNotification: true,
                  announcementTiming: _selectedTiming,
                  customHoursBefore:
                      _selectedTiming == NotificationTiming.custom
                      ? hours
                      : null,
                );
              }
            } else {
              newSettings = null;
            }

            Navigator.pop(context, newSettings);
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

