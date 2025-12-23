// 캘린더 이벤트 스타일 유틸리티
// 이벤트 타입별 색상, 아이콘, 라벨을 제공하는 유틸리티 클래스

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// 캘린더 이벤트의 스타일 정보를 담는 클래스
class CalendarEventStyle {
  final Color color;
  final IconData icon;
  final String label;

  const CalendarEventStyle({
    required this.color,
    required this.icon,
    required this.label,
  });

  /// 이벤트 타입에 따른 스타일을 반환
  /// 
  /// [eventType]은 'deadline', 'announcement', 'interview' 중 하나
  static CalendarEventStyle getStyle(String eventType) {
    switch (eventType) {
      case 'deadline':
        return const CalendarEventStyle(
          color: AppColors.error,
          icon: Icons.event_busy,
          label: AppStrings.deadlineEvent,
        );
      case 'announcement':
        return const CalendarEventStyle(
          color: AppColors.info,
          icon: Icons.campaign,
          label: AppStrings.announcementEvent,
        );
      case 'interview':
        return const CalendarEventStyle(
          color: AppColors.warning,
          icon: Icons.phone_in_talk,
          label: AppStrings.interviewEvent,
        );
      default:
        // 기본값으로 interview 스타일 반환
        return const CalendarEventStyle(
          color: AppColors.warning,
          icon: Icons.phone_in_talk,
          label: AppStrings.interviewEvent,
        );
    }
  }

  /// 이벤트 타입에 따른 색상만 반환
  static Color getColor(String eventType) {
    return getStyle(eventType).color;
  }

  /// 이벤트 타입에 따른 아이콘만 반환
  static IconData getIcon(String eventType) {
    return getStyle(eventType).icon;
  }

  /// 이벤트 타입에 따른 라벨만 반환
  static String getLabel(String eventType) {
    return getStyle(eventType).label;
  }
}







