// 캘린더 화면
// 월간/주간/일간 뷰로 일정을 확인할 수 있는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.calendarTitle),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 오늘로 이동
            },
            child: const Text(AppStrings.today),
          ),
        ],
      ),
      body: Column(
        children: [
          // 뷰 전환 버튼
          _buildViewToggle(context),
          // 캘린더
          Expanded(
            child: _buildCalendar(context),
          ),
          // 선택된 날짜의 일정 목록
          _buildScheduleList(context),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildViewButton(context, AppStrings.monthly, true),
          _buildViewButton(context, AppStrings.weekly, false),
          _buildViewButton(context, AppStrings.daily, false),
        ],
      ),
    );
  }

  Widget _buildViewButton(BuildContext context, String label, bool isSelected) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            // TODO: 뷰 전환
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
            foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
            elevation: isSelected ? 2 : 0,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '캘린더 위젯이 여기에 표시됩니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2024.01.15 (월)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                '선택된 날짜의 일정이 여기에 표시됩니다',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
