// ScheduleItem 모델
// 오늘의 일정 정보를 담는 데이터 모델

import 'package:flutter/material.dart';
import 'application.dart';

class ScheduleItem {
  final String type; // 일정 타입 (마감일, 발표일, 전형 타입 등)
  final IconData icon; // 아이콘
  final Color color; // 색상
  final String company; // 회사명
  final String? position; // 직무명
  final String? timeOrDday; // 시간 또는 D-day (예: "14:30" 또는 "D-0")
  final Application application; // 관련 공고

  ScheduleItem({
    required this.type,
    required this.icon,
    required this.color,
    required this.company,
    this.position,
    this.timeOrDday,
    required this.application,
  });
}

