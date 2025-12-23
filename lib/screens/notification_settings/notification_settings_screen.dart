// 알림 설정 화면
// 전체 알림 및 개별 알림 설정을 관리하는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/notification_timing.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // 알림 설정 상태
  bool _enableAllNotifications = true;
  bool _enableDeadlineNotification = true;
  bool _enableAnnouncementNotification = true;
  bool _enableInterviewNotification = true;

  NotificationTiming _deadlineTiming = NotificationTiming.daysBefore3;
  NotificationTiming _announcementTiming = NotificationTiming.onTheDay;
  NotificationTiming _interviewTiming = NotificationTiming.onTheDay;

  int? _deadlineCustomHours;
  int? _interviewCustomHours;

  TimeOfDay _defaultNotificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notificationSettings)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 전체 알림 활성화
              _buildEnableAllNotifications(context),
              const SizedBox(height: 24),

              // 마감일 알림 설정
              _buildDeadlineNotificationSection(context),
              const SizedBox(height: 24),

              // 발표일 알림 설정
              _buildAnnouncementNotificationSection(context),
              const SizedBox(height: 24),

              // 면접 알림 설정
              _buildInterviewNotificationSection(context),
              const SizedBox(height: 24),

              // 기본 알림 시간 설정
              _buildDefaultNotificationTimeSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnableAllNotifications(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(Icons.notifications, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              AppStrings.enableNotifications,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(
          '모든 알림을 한 번에 켜거나 끌 수 있습니다',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        value: _enableAllNotifications,
        onChanged: (value) {
          setState(() {
            _enableAllNotifications = value;
            if (!value) {
              _enableDeadlineNotification = false;
              _enableAnnouncementNotification = false;
              _enableInterviewNotification = false;
            } else {
              _enableDeadlineNotification = true;
              _enableAnnouncementNotification = true;
              _enableInterviewNotification = true;
            }
          });
        },
      ),
    );
  }

  Widget _buildDeadlineNotificationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_busy, color: AppColors.error),
                const SizedBox(width: 12),
                Text(
                  AppStrings.deadlineNotification,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppStrings.receiveNotification),
              value: _enableDeadlineNotification && _enableAllNotifications,
              onChanged: _enableAllNotifications
                  ? (value) {
                      setState(() {
                        _enableDeadlineNotification = value;
                      });
                    }
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            if (_enableDeadlineNotification && _enableAllNotifications) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.notificationTiming,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RadioGroup<NotificationTiming>(
                groupValue: _deadlineTiming,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _deadlineTiming = value;
                      if (value == NotificationTiming.custom) {
                        _showCustomHoursDialog(
                          context,
                          initialHours: _deadlineCustomHours ?? 24,
                          onSaved: (hours) {
                            setState(() {
                              _deadlineCustomHours = hours;
                            });
                          },
                        );
                      }
                    });
                  }
                },
                child: Column(
                  children: [
                    _buildTimingRadio(
                      context,
                      NotificationTiming.daysBefore7,
                      AppStrings.daysBefore7,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.daysBefore3,
                      AppStrings.daysBefore3,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.daysBefore1,
                      AppStrings.daysBefore1,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.onTheDay,
                      AppStrings.onTheDay,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.custom,
                      _deadlineTiming == NotificationTiming.custom &&
                              _deadlineCustomHours != null
                          ? '${AppStrings.customTime} ($_deadlineCustomHours시간 전)'
                          : AppStrings.customTime,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementNotificationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign, color: AppColors.info),
                const SizedBox(width: 12),
                Text(
                  AppStrings.announcementNotification,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppStrings.receiveNotification),
              value: _enableAnnouncementNotification && _enableAllNotifications,
              onChanged: _enableAllNotifications
                  ? (value) {
                      setState(() {
                        _enableAnnouncementNotification = value;
                      });
                    }
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            if (_enableAnnouncementNotification && _enableAllNotifications) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.notificationTiming,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RadioGroup<NotificationTiming>(
                groupValue: _announcementTiming,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _announcementTiming = value;
                    });
                  }
                },
                child: Column(
                  children: [
                    _buildTimingRadio(
                      context,
                      NotificationTiming.onTheDay,
                      AppStrings.onTheDay,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.daysBefore1,
                      AppStrings.daysBefore1,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewNotificationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_in_talk, color: AppColors.warning),
                const SizedBox(width: 12),
                Text(
                  AppStrings.interviewNotification,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppStrings.receiveNotification),
              value: _enableInterviewNotification && _enableAllNotifications,
              onChanged: _enableAllNotifications
                  ? (value) {
                      setState(() {
                        _enableInterviewNotification = value;
                      });
                    }
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            if (_enableInterviewNotification && _enableAllNotifications) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.notificationTiming,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RadioGroup<NotificationTiming>(
                groupValue: _interviewTiming,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _interviewTiming = value;
                      if (value == NotificationTiming.custom) {
                        _showCustomHoursDialog(
                          context,
                          initialHours: _interviewCustomHours ?? 1,
                          onSaved: (hours) {
                            setState(() {
                              _interviewCustomHours = hours;
                            });
                          },
                        );
                      }
                    });
                  }
                },
                child: Column(
                  children: [
                    _buildTimingRadio(
                      context,
                      NotificationTiming.daysBefore1,
                      AppStrings.daysBefore1,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.onTheDay,
                      AppStrings.onTheDay,
                    ),
                    _buildTimingRadio(
                      context,
                      NotificationTiming.custom,
                      _interviewTiming == NotificationTiming.custom &&
                              _interviewCustomHours != null
                          ? '${AppStrings.timeBefore} ($_interviewCustomHours시간 전)'
                          : '${AppStrings.timeBefore} (예: 1시간 전)',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultNotificationTimeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  AppStrings.defaultNotificationTime,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _defaultNotificationTime,
                );
                if (picked != null) {
                  setState(() {
                    _defaultNotificationTime = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_defaultNotificationTime),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingRadio(
    BuildContext context,
    NotificationTiming value,
    String label,
  ) {
    return RadioListTile<NotificationTiming>(
      title: Text(label),
      value: value,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showCustomHoursDialog(
    BuildContext context, {
    required int initialHours,
    required Function(int) onSaved,
  }) async {
    final hoursController = TextEditingController(
      text: initialHours.toString(),
    );
    bool isValid = true;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('사용자 지정 시간'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('알림을 받을 시간을 입력하세요 (시간 단위)'),
              const SizedBox(height: 16),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '시간 전',
                  hintText: '24',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorText: !isValid && hoursController.text.trim().isEmpty
                      ? '시간을 입력해주세요.'
                      : null,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  final hours = int.tryParse(value.trim());
                  setState(() {
                    isValid = hours != null && hours > 0;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final hours = int.tryParse(hoursController.text.trim());
                if (hours != null && hours > 0) {
                  onSaved(hours);
                  Navigator.pop(dialogContext);
                } else {
                  setState(() {
                    isValid = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );

    hoursController.dispose();
  }
}
