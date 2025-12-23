// TodayScheduleService
// 오늘의 일정 계산 로직을 담당하는 서비스
// - 마감일이 오늘인 경우
// - 발표일이 오늘인 경우
// - 다음 전형 일정이 오늘인 경우
// - 시간순으로 정렬

import 'package:flutter/material.dart';
import '../models/application.dart';
import '../models/schedule_item.dart';
import '../constants/app_colors.dart';

class TodayScheduleService {
  // 오늘의 일정 계산
  static List<ScheduleItem> getTodaySchedules(
    List<Application> applications,
  ) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final schedules = <ScheduleItem>[];

    for (final app in applications) {
      // 마감일이 오늘인 경우
      final deadlineDate = DateTime(
        app.deadline.year,
        app.deadline.month,
        app.deadline.day,
      );
      if (deadlineDate == todayDate) {
        schedules.add(ScheduleItem(
          type: '마감일',
          icon: Icons.event_busy,
          color: AppColors.error,
          company: app.companyName,
          position: app.position,
          timeOrDday: 'D-0',
          application: app,
        ));
      }

      // 발표일이 오늘인 경우
      if (app.announcementDate != null) {
        final announcementDate = DateTime(
          app.announcementDate!.year,
          app.announcementDate!.month,
          app.announcementDate!.day,
        );
        if (announcementDate == todayDate) {
          schedules.add(ScheduleItem(
            type: '발표일',
            icon: Icons.campaign,
            color: AppColors.primary,
            company: app.companyName,
            position: app.position,
            timeOrDday: null,
            application: app,
          ));
        }
      }

      // 다음 전형 일정이 오늘인 경우
      for (final stage in app.nextStages) {
        final stageDate = DateTime(
          stage.date.year,
          stage.date.month,
          stage.date.day,
        );
        if (stageDate == todayDate) {
          schedules.add(ScheduleItem(
            type: stage.type,
            icon: Icons.phone_in_talk,
            color: AppColors.info,
            company: app.companyName,
            position: app.position,
            timeOrDday: stage.date.hour != 0 || stage.date.minute != 0
                ? '${stage.date.hour.toString().padLeft(2, '0')}:${stage.date.minute.toString().padLeft(2, '0')}'
                : null,
            application: app,
          ));
        }
      }
    }

    // 시간순으로 정렬
    schedules.sort((a, b) {
      return a.application.deadline.compareTo(b.application.deadline);
    });

    return schedules;
  }
}

