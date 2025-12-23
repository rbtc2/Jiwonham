// DateTimeFormUtils
// 폼에서 사용하는 DateTime 처리 유틸리티

import 'package:flutter/material.dart';

class DateTimeFormUtils {
  // DateTime과 TimeOfDay를 결합하여 새로운 DateTime 생성
  // includeTime이 false이거나 time이 null이면 날짜만 반환 (시간은 0:0:0)
  static DateTime? combineDateTime(
    DateTime? date,
    TimeOfDay? time,
    bool includeTime,
  ) {
    if (date == null) return null;
    if (includeTime && time != null) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }
    return DateTime(date.year, date.month, date.day);
  }

  // DateTime에서 시간 정보 추출
  // 시간이 0:0:0이 아니면 true와 TimeOfDay 반환, 아니면 false와 null 반환
  static ({bool includeTime, TimeOfDay? time}) extractTimeInfo(
    DateTime dateTime,
  ) {
    if (dateTime.hour != 0 || dateTime.minute != 0) {
      return (
        includeTime: true,
        time: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      );
    }
    return (includeTime: false, time: null);
  }

  // DateTime을 날짜만으로 변환 (시간 제거)
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // DateTime이 시간을 포함하는지 확인
  static bool hasTime(DateTime dateTime) {
    return dateTime.hour != 0 || dateTime.minute != 0;
  }
}

