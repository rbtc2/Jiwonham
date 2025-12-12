// NotificationSettings 모델
// 알림 설정 정보를 담는 데이터 모델

import 'notification_timing.dart';

class NotificationSettings {
  final bool deadlineNotification;      // 마감일 알림 활성화
  final NotificationTiming? deadlineTiming; // 마감일 알림 시점
  final bool announcementNotification; // 발표일 알림 활성화
  final NotificationTiming? announcementTiming; // 발표일 알림 시점
  final bool interviewNotification;     // 면접 알림 활성화
  final NotificationTiming? interviewTiming; // 면접 알림 시점
  final int? customHoursBefore;         // 사용자 지정 시간 (시간 전)

  NotificationSettings({
    this.deadlineNotification = false,
    this.deadlineTiming,
    this.announcementNotification = false,
    this.announcementTiming,
    this.interviewNotification = false,
    this.interviewTiming,
    this.customHoursBefore,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'deadlineNotification': deadlineNotification,
      'deadlineTiming': deadlineTiming?.name,
      'announcementNotification': announcementNotification,
      'announcementTiming': announcementTiming?.name,
      'interviewNotification': interviewNotification,
      'interviewTiming': interviewTiming?.name,
      'customHoursBefore': customHoursBefore,
    };
  }

  // JSON 역직렬화
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      deadlineNotification: json['deadlineNotification'] as bool? ?? false,
      deadlineTiming: json['deadlineTiming'] != null
          ? NotificationTiming.values.firstWhere(
              (e) => e.name == json['deadlineTiming'],
              orElse: () => NotificationTiming.daysBefore3,
            )
          : null,
      announcementNotification: json['announcementNotification'] as bool? ?? false,
      announcementTiming: json['announcementTiming'] != null
          ? NotificationTiming.values.firstWhere(
              (e) => e.name == json['announcementTiming'],
              orElse: () => NotificationTiming.onTheDay,
            )
          : null,
      interviewNotification: json['interviewNotification'] as bool? ?? false,
      interviewTiming: json['interviewTiming'] != null
          ? NotificationTiming.values.firstWhere(
              (e) => e.name == json['interviewTiming'],
              orElse: () => NotificationTiming.onTheDay,
            )
          : null,
      customHoursBefore: json['customHoursBefore'] as int?,
    );
  }

  // 복사 생성자
  NotificationSettings copyWith({
    bool? deadlineNotification,
    NotificationTiming? deadlineTiming,
    bool? announcementNotification,
    NotificationTiming? announcementTiming,
    bool? interviewNotification,
    NotificationTiming? interviewTiming,
    int? customHoursBefore,
  }) {
    return NotificationSettings(
      deadlineNotification: deadlineNotification ?? this.deadlineNotification,
      deadlineTiming: deadlineTiming ?? this.deadlineTiming,
      announcementNotification: announcementNotification ?? this.announcementNotification,
      announcementTiming: announcementTiming ?? this.announcementTiming,
      interviewNotification: interviewNotification ?? this.interviewNotification,
      interviewTiming: interviewTiming ?? this.interviewTiming,
      customHoursBefore: customHoursBefore ?? this.customHoursBefore,
    );
  }
}
