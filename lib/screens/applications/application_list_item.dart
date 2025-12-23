// 공고 목록 아이템 위젯
// 공고 목록에서 각 공고를 표시하는 재사용 가능한 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/application.dart';
import '../../models/notification_settings.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/modern_card.dart';
import '../application_detail/application_detail_screen.dart';

class ApplicationListItem extends StatelessWidget {
  final Application application;
  final VoidCallback? onChanged;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onLongPress;

  const ApplicationListItem({
    super.key,
    required this.application,
    this.onChanged,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // PHASE 7: 선택 모드 진입 시 애니메이션
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // 선택 모드일 때만 배경색 변경, 일반 모드일 때는 투명
        color: isSelectionMode && isSelected
            ? AppColors.primary.withValues(alpha: 0.15)
            : null,
        borderRadius: BorderRadius.circular(16),
        border: isSelectionMode && isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: GestureDetector(
        onLongPress: () {
          // PHASE 1: 롱프레스 시 선택 모드 활성화
          if (onLongPress != null) {
            onLongPress!();
          }
        },
        child: ModernCard(
          padding: const EdgeInsets.all(20.0),
          borderRadius: BorderRadius.circular(16),
          onTap: isSelectionMode
              ? () {
                  // 선택 모드일 때는 항목 선택/해제 토글
                  if (onSelectionChanged != null) {
                    onSelectionChanged!(!isSelected);
                  }
                }
              : () async {
                  // 일반 모드일 때는 상세 화면으로 이동
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ApplicationDetailScreen(application: application),
                    ),
                  );
                  // 상태 변경 등으로 인해 변경사항이 있으면 콜백 호출
                  if (result == true && onChanged != null) {
                    onChanged!();
                  }
                },
          child: Stack(
          children: [
            // 내용 영역 (항상 같은 위치 - 체크박스와 관계없이 고정)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 알람 아이콘과 D-day 배지
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 알람이 설정되어 있으면 표시 (D-day 배지 앞에 위치)
                    if (_hasNotification(application.notificationSettings)) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: AppColors.warning,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // D-day 배지 (항상 제일 우측에 위치)
                    DDayBadge(deadline: application.deadline),
                  ],
                ),
                const SizedBox(height: 16),

                // 회사명
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        application.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 직무명
                if (application.position != null &&
                    application.position!.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          application.position!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // 날짜 정보
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '마감: ${_formatDate(application.deadline)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // 다음 전형 일정이 있으면 표시
                    if (application.nextStages.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.phone_in_talk,
                              size: 16,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '면접: ${_formatDate(application.nextStages.first.date)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 상태 칩
                StatusChip(status: application.status),
              ],
            ),
            // 선택 모드일 때 체크박스를 왼쪽 상단에 오버레이로 배치
            if (isSelectionMode)
              Positioned(
                left: 0,
                top: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // 체크박스 영역 클릭 시 선택/해제
                      if (onSelectionChanged != null) {
                        onSelectionChanged!(!isSelected);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: 1.0,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            if (onSelectionChanged != null && value != null) {
                              onSelectionChanged!(value);
                            }
                          },
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  // 알람이 설정되어 있는지 확인하는 헬퍼 메서드
  bool _hasNotification(NotificationSettings notificationSettings) {
    return notificationSettings.deadlineNotification ||
        notificationSettings.announcementNotification ||
        notificationSettings.interviewNotification;
  }
}
