// 공고 목록 아이템 위젯
// 공고 목록에서 각 공고를 표시하는 재사용 가능한 위젯

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../models/notification_settings.dart';
import '../../widgets/d_day_badge.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          padding: const EdgeInsets.all(16.0),
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
                // 상단: 알람 아이콘, 지원 완료 배지, 지원서 링크, 상태 칩, D-day 배지
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 왼쪽: 알람 아이콘 + 지원 완료 배지
                    Row(
                      children: [
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
                        if (application.isApplied)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '지원완료',
                                  style: Theme.of(context)
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    // 오른쪽: 지원서 링크 아이콘 + 상태 칩 + D-day 배지
                    Row(
                      children: [
                        // 지원서 링크 아이콘 (있으면)
                        if (application.applicationLink != null) ...[
                          IconButton(
                            icon: Icon(
                              Icons.link,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: () async {
                              try {
                                Uri uri = Uri.parse(application.applicationLink!);
                                if (!uri.hasScheme) {
                                  uri = Uri.parse('https://${application.applicationLink}');
                                }
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('링크를 열 수 없습니다: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: '지원서 링크 열기',
                          ),
                          const SizedBox(width: 8),
                        ],
                        // 상태 칩 (D-day 배지와 동일한 스타일)
                        _buildStatusBadge(context),
                        const SizedBox(width: 8),
                        DDayBadge(deadline: application.deadline),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 회사명
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        application.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 직무명
                if (application.position != null &&
                    application.position!.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          application.position!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // 구분 및 근무지 배지
                if (application.experienceLevel != null ||
                    (application.workplace != null &&
                        application.workplace!.isNotEmpty)) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (application.experienceLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                application.experienceLevel!.label,
                                style: Theme.of(context)
                                    .textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (application.workplace != null &&
                          application.workplace!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  application.workplace!,
                                  style: Theme.of(context)
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // 날짜 정보
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 마감일
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
                    // 서류 발표일
                    if (application.announcementDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.campaign,
                              size: 16,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '발표: ${_formatDate(application.announcementDate!)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    // 다음 전형 일정
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
                            '${application.nextStages.first.type}: ${_formatDate(application.nextStages.first.date)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
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

  // 상태 배지 빌더 (D-day 배지와 동일한 스타일)
  Widget _buildStatusBadge(BuildContext context) {
    final status = application.status;
    
    String statusText;
    Color statusColor;
    
    switch (status) {
      case ApplicationStatus.notApplied:
        statusText = '지원 전';
        statusColor = AppColors.textSecondary;
        break;
      case ApplicationStatus.applied:
        statusText = '지원 완료';
        statusColor = AppColors.primary;
        break;
      case ApplicationStatus.inProgress:
        statusText = '진행중';
        statusColor = AppColors.warning;
        break;
      case ApplicationStatus.passed:
        statusText = '합격';
        statusColor = AppColors.success;
        break;
      case ApplicationStatus.rejected:
        statusText = '불합격';
        statusColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // 알람이 설정되어 있는지 확인하는 헬퍼 메서드
  bool _hasNotification(NotificationSettings notificationSettings) {
    return notificationSettings.deadlineNotification ||
        notificationSettings.announcementNotification ||
        notificationSettings.interviewNotification;
  }
}
