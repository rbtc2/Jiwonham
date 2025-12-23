// 오늘의 일정 섹션 위젯
// 오늘의 일정 목록을 표시하는 섹션 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/schedule_item.dart';
import '../../../models/application.dart';
import '../../application_detail/application_detail_screen.dart';
import 'schedule_item.dart';

class TodayScheduleSection extends StatelessWidget {
  final List<ScheduleItem> schedules;
  final Function(Application)? onScheduleTap;

  const TodayScheduleSection({
    super.key,
    required this.schedules,
    this.onScheduleTap,
  });

  void _handleScheduleTap(BuildContext context, ScheduleItem schedule) {
    if (onScheduleTap != null) {
      onScheduleTap!(schedule.application);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetailScreen(
          application: schedule.application,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.todaySchedule,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (schedules.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '오늘 일정이 없습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ...schedules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final schedule = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 24),
                        InkWell(
                          onTap: () => _handleScheduleTap(context, schedule),
                          child: ScheduleItemWidget(
                            icon: schedule.icon,
                            type: schedule.type,
                            company: schedule.company,
                            timeOrDday: schedule.timeOrDday,
                            color: schedule.color,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

