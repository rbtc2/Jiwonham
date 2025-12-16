// Phase 9-4: 통계 화면 헬퍼 함수들
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/application_status.dart';
import '../models/monthly_display_period.dart';
import '../models/period_type.dart';

/// 월별 표시 기간 텍스트 변환
String getMonthlyDisplayPeriodText(MonthlyDisplayPeriod period) {
  switch (period) {
    case MonthlyDisplayPeriod.last3Months:
      return AppStrings.last3Months;
    case MonthlyDisplayPeriod.last6Months:
      return AppStrings.last6Months;
    case MonthlyDisplayPeriod.last12Months:
      return '지난 12개월';
    case MonthlyDisplayPeriod.thisYear:
      return AppStrings.thisYear;
    case MonthlyDisplayPeriod.all:
      return AppStrings.allPeriod;
  }
}

/// 상태 텍스트 변환
String getStatusText(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.notApplied:
      return AppStrings.notApplied;
    case ApplicationStatus.applied:
      return '지원완료';
    case ApplicationStatus.inProgress:
      return AppStrings.inProgress;
    case ApplicationStatus.passed:
      return AppStrings.passed;
    case ApplicationStatus.rejected:
      return AppStrings.rejected;
  }
}

/// 상태 색상 가져오기
Color getStatusColor(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.notApplied:
      return AppColors.textSecondary;
    case ApplicationStatus.applied:
      return AppColors.info;
    case ApplicationStatus.inProgress:
      return AppColors.warning;
    case ApplicationStatus.passed:
      return AppColors.success;
    case ApplicationStatus.rejected:
      return AppColors.error;
  }
}

/// 필터 키 생성 (캐시 무효화 감지용)
String getFilterKey(
  PeriodType selectedPeriod,
  DateTime? customStartDate,
  DateTime? customEndDate,
  int filteredApplicationsLength,
) {
  return '${selectedPeriod}_${customStartDate?.millisecondsSinceEpoch}_${customEndDate?.millisecondsSinceEpoch}_$filteredApplicationsLength';
}

/// 기간 필터에 따라 월별 표시 기간 자동 조정
MonthlyDisplayPeriod? adjustMonthlyDisplayPeriod(PeriodType selectedPeriod) {
  switch (selectedPeriod) {
    case PeriodType.thisMonth:
      return MonthlyDisplayPeriod.last3Months;
    case PeriodType.last3Months:
      return MonthlyDisplayPeriod.last3Months;
    case PeriodType.last6Months:
      return MonthlyDisplayPeriod.last6Months;
    case PeriodType.thisYear:
      return MonthlyDisplayPeriod.thisYear;
    case PeriodType.all:
      return MonthlyDisplayPeriod.all;
    case PeriodType.custom:
      // 사용자 지정 기간은 현재 설정 유지
      return null;
  }
}

/// 기간 필터링 적용
List<Application> applyPeriodFilter(
  List<Application> allApplications,
  PeriodType selectedPeriod,
  DateTime? customStartDate,
  DateTime? customEndDate,
) {
  final now = DateTime.now();
  List<Application> filtered = List.from(allApplications);

  switch (selectedPeriod) {
    case PeriodType.thisMonth:
      final startOfMonth = DateTime(now.year, now.month, 1);
      filtered = filtered
          .where(
            (app) =>
                app.createdAt.isAfter(startOfMonth) ||
                app.createdAt.isAtSameMomentAs(startOfMonth),
          )
          .toList();
      break;
    case PeriodType.last3Months:
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      filtered = filtered
          .where(
            (app) =>
                app.createdAt.isAfter(threeMonthsAgo) ||
                app.createdAt.isAtSameMomentAs(threeMonthsAgo),
          )
          .toList();
      break;
    case PeriodType.last6Months:
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      filtered = filtered
          .where(
            (app) =>
                app.createdAt.isAfter(sixMonthsAgo) ||
                app.createdAt.isAtSameMomentAs(sixMonthsAgo),
          )
          .toList();
      break;
    case PeriodType.thisYear:
      final startOfYear = DateTime(now.year, 1, 1);
      filtered = filtered
          .where(
            (app) =>
                app.createdAt.isAfter(startOfYear) ||
                app.createdAt.isAtSameMomentAs(startOfYear),
          )
          .toList();
      break;
    case PeriodType.custom:
      if (customStartDate != null && customEndDate != null) {
        // 종료일의 끝 시간까지 포함하기 위해 23:59:59로 설정
        final endDate = DateTime(
          customEndDate.year,
          customEndDate.month,
          customEndDate.day,
          23,
          59,
          59,
        );
        filtered = filtered
            .where(
              (app) =>
                  (app.createdAt.isAfter(customStartDate) ||
                      app.createdAt.isAtSameMomentAs(customStartDate)) &&
                  (app.createdAt.isBefore(endDate) ||
                      app.createdAt.isAtSameMomentAs(endDate)),
            )
            .toList();
      }
      break;
    case PeriodType.all:
      // 전체 기간 - 필터링 없음
      break;
  }

  return filtered;
}

/// 통계 계산 결과 캐싱 및 갱신
class StatisticsCache {
  int? totalApplications;
  int? notApplied;
  int? inProgress;
  int? passed;
  int? rejected;
  String? filterKey;

  void update(
    List<Application> filteredApplications,
    String currentFilterKey,
  ) {
    if (filterKey == currentFilterKey && totalApplications != null) {
      return; // 캐시가 유효하면 재계산하지 않음
    }

    totalApplications = filteredApplications.length;
    notApplied = filteredApplications
        .where((app) => app.status == ApplicationStatus.notApplied)
        .length;
    inProgress = filteredApplications
        .where((app) => app.status == ApplicationStatus.inProgress)
        .length;
    passed = filteredApplications
        .where((app) => app.status == ApplicationStatus.passed)
        .length;
    rejected = filteredApplications
        .where((app) => app.status == ApplicationStatus.rejected)
        .length;
    filterKey = currentFilterKey;
  }
}

