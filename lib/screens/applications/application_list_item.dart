// 공고 목록 아이템 위젯
// 공고 목록에서 각 공고를 표시하는 재사용 가능한 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';
import '../application_detail/application_detail_screen.dart';

class ApplicationListItem extends StatelessWidget {
  final String companyName;
  final String? position;
  final DateTime deadline;
  final ApplicationStatus status;
  final bool isApplied;
  final DateTime? interviewDate;

  const ApplicationListItem({
    super.key,
    required this.companyName,
    this.position,
    required this.deadline,
    required this.status,
    this.isApplied = false,
    this.interviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ApplicationDetailScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 체크박스와 D-day 배지
              Row(
                children: [
                  Checkbox(
                    value: isApplied,
                    onChanged: (value) {
                      // TODO: 지원 완료 상태 변경
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Spacer(),
                  DDayBadge(deadline: deadline),
                ],
              ),
              const SizedBox(height: 12),

              // 회사명
              Row(
                children: [
                  Icon(Icons.business, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      companyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 직무명
              if (position != null && position!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        position!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // 날짜 정보
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '마감: ${_formatDate(deadline)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  if (interviewDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.phone_in_talk, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '면접: ${_formatDate(interviewDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // 상태 칩
              StatusChip(status: status),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
