// NotificationService
// 알림 기능을 관리하는 서비스
// - 마감일 알림
// - 발표일 알림
// - 면접일 알림

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/application.dart';
import '../models/notification_timing.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // 알림 채널 ID 상수
  static const String _deadlineChannelId = 'deadline_notifications';
  static const String _announcementChannelId = 'announcement_notifications';
  static const String _interviewChannelId = 'interview_notifications';

  // 알림 채널 이름
  static const String _deadlineChannelName = '마감일 알림';
  static const String _announcementChannelName = '발표일 알림';
  static const String _interviewChannelName = '면접일 알림';

  // 알림 채널 설명
  static const String _deadlineChannelDescription = '공고 마감일 알림';
  static const String _announcementChannelDescription = '발표일 알림';
  static const String _interviewChannelDescription = '면접 일정 알림';

  /// 알림 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // 타임존 초기화
      tz.initializeTimeZones();
      // 한국 시간대 설정
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      // Android 초기화 설정
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 초기화 설정 (향후 iOS 지원 시)
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 초기화 설정 통합
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // 알림 플러그인 초기화
      final bool? initialized = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != true) {
        return false;
      }

      // 알림 채널 생성
      await _createNotificationChannels();

      // 알림 권한 요청 (Android 13 이상)
      await _requestNotificationPermission();

      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 알림 채널 생성
  Future<void> _createNotificationChannels() async {
    // 마감일 알림 채널
    const AndroidNotificationChannel deadlineChannel = AndroidNotificationChannel(
      _deadlineChannelId,
      _deadlineChannelName,
      description: _deadlineChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // 발표일 알림 채널
    const AndroidNotificationChannel announcementChannel =
        AndroidNotificationChannel(
      _announcementChannelId,
      _announcementChannelName,
      description: _announcementChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // 면접일 알림 채널
    const AndroidNotificationChannel interviewChannel =
        AndroidNotificationChannel(
      _interviewChannelId,
      _interviewChannelName,
      description: _interviewChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deadlineChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(announcementChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(interviewChannel);
  }

  /// 알림 권한 요청
  Future<bool> _requestNotificationPermission() async {
    // Android 13 이상에서만 필요
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 처리 로직 (필요 시 구현)
  }

  /// 공고의 모든 알림 스케줄링
  Future<void> scheduleApplicationNotifications(
    Application application,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 기존 알림 취소
    await cancelApplicationNotifications(application.id);

    // 보관함에 있는 공고는 알림 스케줄링하지 않음
    if (application.isArchived) {
      return;
    }

    // 마감일 알림 스케줄링
    if (application.notificationSettings.deadlineNotification &&
        application.notificationSettings.deadlineTiming != null) {
      await _scheduleDeadlineNotification(application);
    }

    // 발표일 알림 스케줄링
    if (application.notificationSettings.announcementNotification &&
        application.announcementDate != null &&
        application.notificationSettings.announcementTiming != null) {
      await _scheduleAnnouncementNotification(application);
    }

    // 면접일 알림 스케줄링
    if (application.notificationSettings.interviewNotification &&
        application.interviewSchedule != null &&
        application.notificationSettings.interviewTiming != null) {
      await _scheduleInterviewNotification(application);
    }
  }

  /// 마감일 알림 스케줄링
  Future<void> _scheduleDeadlineNotification(Application application) async {
    final timing = application.notificationSettings.deadlineTiming!;
    final notificationDate = _calculateNotificationDate(
      application.deadline,
      timing,
      application.notificationSettings.customHoursBefore,
    );

    if (notificationDate == null || notificationDate.isBefore(DateTime.now())) {
      return; // 과거 날짜는 스케줄링하지 않음
    }

    final notificationId = _generateNotificationId(
      application.id,
      'deadline',
    );

    await _notifications.zonedSchedule(
      notificationId,
      '${application.companyName} 공고 마감일',
      _getDeadlineNotificationBody(application, timing),
      tz.TZDateTime.from(notificationDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _deadlineChannelId,
          _deadlineChannelName,
          channelDescription: _deadlineChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 발표일 알림 스케줄링
  Future<void> _scheduleAnnouncementNotification(
    Application application,
  ) async {
    if (application.announcementDate == null) {
      return;
    }

    final timing = application.notificationSettings.announcementTiming!;
    final notificationDate = _calculateNotificationDate(
      application.announcementDate!,
      timing,
      application.notificationSettings.customHoursBefore,
    );

    if (notificationDate == null || notificationDate.isBefore(DateTime.now())) {
      return; // 과거 날짜는 스케줄링하지 않음
    }

    final notificationId = _generateNotificationId(
      application.id,
      'announcement',
    );

    await _notifications.zonedSchedule(
      notificationId,
      '${application.companyName} 발표일',
      _getAnnouncementNotificationBody(application, timing),
      tz.TZDateTime.from(notificationDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _announcementChannelId,
          _announcementChannelName,
          channelDescription: _announcementChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 면접일 알림 스케줄링
  Future<void> _scheduleInterviewNotification(Application application) async {
    if (application.interviewSchedule == null ||
        application.interviewSchedule!.date == null) {
      return;
    }

    final timing = application.notificationSettings.interviewTiming!;
    final interviewDate = application.interviewSchedule!.date!;
    final notificationDate = _calculateNotificationDate(
      interviewDate,
      timing,
      application.notificationSettings.customHoursBefore,
    );

    if (notificationDate == null || notificationDate.isBefore(DateTime.now())) {
      return; // 과거 날짜는 스케줄링하지 않음
    }

    final notificationId = _generateNotificationId(
      application.id,
      'interview',
    );

    await _notifications.zonedSchedule(
      notificationId,
      '${application.companyName} 면접 일정',
      _getInterviewNotificationBody(application, timing),
      tz.TZDateTime.from(notificationDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _interviewChannelId,
          _interviewChannelName,
          channelDescription: _interviewChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 알림 날짜 계산
  DateTime? _calculateNotificationDate(
    DateTime targetDate,
    NotificationTiming timing,
    int? customHoursBefore,
  ) {
    switch (timing) {
      case NotificationTiming.daysBefore7:
        return targetDate.subtract(const Duration(days: 7));
      case NotificationTiming.daysBefore3:
        return targetDate.subtract(const Duration(days: 3));
      case NotificationTiming.daysBefore1:
        return targetDate.subtract(const Duration(days: 1));
      case NotificationTiming.onTheDay:
        // 당일 오전 9시에 알림
        return DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          9,
          0,
        );
      case NotificationTiming.custom:
        if (customHoursBefore != null) {
          return targetDate.subtract(Duration(hours: customHoursBefore));
        }
        return null;
    }
  }

  /// 알림 ID 생성 (공고 ID와 타입 기반)
  int _generateNotificationId(String applicationId, String type) {
    // 공고 ID의 해시코드를 기반으로 고유한 ID 생성
    final baseId = applicationId.hashCode.abs() % 100000;
    final typeOffset = type == 'deadline'
        ? 0
        : type == 'announcement'
            ? 100000
            : 200000;
    return baseId + typeOffset;
  }

  /// 마감일 알림 본문 생성
  String _getDeadlineNotificationBody(
    Application application,
    NotificationTiming timing,
  ) {
    final daysUntil = application.daysUntilDeadline;
    if (daysUntil < 0) {
      return '마감일이 지났습니다.';
    } else if (daysUntil == 0) {
      return '오늘 마감입니다!';
    } else {
      return 'D-$daysUntil - ${application.position ?? "공고"} 마감일이 다가옵니다.';
    }
  }

  /// 발표일 알림 본문 생성
  String _getAnnouncementNotificationBody(
    Application application,
    NotificationTiming timing,
  ) {
    return '${application.position ?? "공고"} 발표일이 다가옵니다.';
  }

  /// 면접일 알림 본문 생성
  String _getInterviewNotificationBody(
    Application application,
    NotificationTiming timing,
  ) {
    final schedule = application.interviewSchedule!;
    if (schedule.date != null) {
      final date = schedule.date!;
      final timeStr =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '면접 일정: ${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} $timeStr';
    }
    return '면접 일정이 다가옵니다.';
  }

  /// 공고의 모든 알림 취소
  Future<void> cancelApplicationNotifications(String applicationId) async {
    if (!_isInitialized) {
      return;
    }

    // 마감일, 발표일, 면접일 알림 모두 취소
    await _notifications.cancel(
      _generateNotificationId(applicationId, 'deadline'),
    );
    await _notifications.cancel(
      _generateNotificationId(applicationId, 'announcement'),
    );
    await _notifications.cancel(
      _generateNotificationId(applicationId, 'interview'),
    );
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      return;
    }
    await _notifications.cancelAll();
  }

  /// 예약된 알림 목록 가져오기 (디버깅용)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      return [];
    }
    return await _notifications.pendingNotificationRequests();
  }
}
