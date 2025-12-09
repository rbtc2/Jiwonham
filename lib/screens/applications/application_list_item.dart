// 공고 목록 아이템 위젯
// 공고 목록에서 각 공고를 표시하는 재사용 가능한 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/application.dart';
import '../../widgets/d_day_badge.dart';
import '../../widgets/status_chip.dart';
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
            ? AppColors.primary.withValues(alpha: 0.1)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelectionMode && isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        // 기본 카드 색상을 흰색으로 설정
        color: AppColors.surface,
        child: InkWell(
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
          onLongPress: () {
            // PHASE 1: 롱프레스 시 선택 모드 활성화
            if (onLongPress != null) {
              onLongPress!();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 내용 영역 (항상 같은 위치 - 체크박스와 관계없이 고정)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: D-day 배지
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [DDayBadge(deadline: application.deadline)],
                    ),
                    const SizedBox(height: 12),

                    // 회사명
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            application.companyName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 직무명
                    if (application.position != null &&
                        application.position!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              application.position!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 날짜 정보
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '마감: ${_formatDate(application.deadline)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        // 다음 전형 일정이 있으면 표시
                        if (application.nextStages.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_in_talk,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '면접: ${_formatDate(application.nextStages.first.date)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 상태 칩
                    StatusChip(status: application.status),
                  ],
                ),
              ),
              // 선택 모드일 때 체크박스를 왼쪽에 오버레이로 배치
              // 텍스트는 항상 같은 위치(16px 패딩)에 유지되므로 밀리지 않음
              if (isSelectionMode)
                Positioned(
                  left: 4,
                  top: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // 체크박스 영역 클릭 시 선택/해제
                        if (onSelectionChanged != null) {
                          onSelectionChanged!(!isSelected);
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 48,
                        height: 48,
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
}
