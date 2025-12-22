// 캘린더 일정 목록 위젯
// 하단에 선택된 날짜의 일정 목록을 표시

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/modern_card.dart';
import '../../../widgets/modern_section_header.dart';
import 'calendar_schedule_item.dart';

class CalendarScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final String Function(Map<String, dynamic>) getEventTitle;
  final Future<void> Function(Map<String, dynamic>) onEventTap;

  const CalendarScheduleList({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.getEventTitle,
    required this.onEventTap,
  });

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = _getDayOfWeek(selectedDate);
    final dateText = '${_formatDate(selectedDate)} ($dayOfWeek)';

    return ModernCard(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernSectionHeader(
              title: dateText,
              icon: Icons.event_outlined,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_busy_outlined,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.noSchedule,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '이 날짜에는 일정이 없습니다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...events.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CalendarScheduleItem(
                    event: event,
                    eventTitle: getEventTitle(event),
                    onTap: () => onEventTap(event),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

