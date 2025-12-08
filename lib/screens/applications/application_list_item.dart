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

  const ApplicationListItem({
    super.key,
    required this.application,
    this.onChanged,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // 전체 카드 클릭 영역
          InkWell(
            onTap: isSelectionMode
                ? () {
                    // 선택 모드일 때는 카드 클릭 시 체크박스 토글
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
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 체크박스와 D-day 배지
                  Row(
                    children: [
                      // Phase 2: 선택 모드일 때는 선택 체크박스, 아닐 때는 지원 완료 체크박스
                      // 체크박스는 Stack의 위 레이어에 배치하여 클릭 이벤트를 독립적으로 처리
                      SizedBox(
                        width: 48,
                        height: 48,
                        // 투명한 공간을 만들어 체크박스 영역 확보
                      ),
                      const Spacer(),
                      DDayBadge(deadline: application.deadline),
                    ],
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
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '마감: ${_formatDate(application.deadline)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // 다음 전형 일정이 있으면 표시
                      if (application.nextStages.isNotEmpty) ...[
                        const SizedBox(width: 16),
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
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 상태 칩
                  StatusChip(status: application.status),
                ],
              ),
            ),
          ),
          // 체크박스를 Stack의 위 레이어에 배치하여 클릭 이벤트를 독립적으로 처리
          Positioned(
            left: 16,
            top: 16,
            child: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (onSelectionChanged != null && value != null) {
                        onSelectionChanged!(value);
                      }
                    },
                    activeColor: AppColors.primary,
                  )
                : Checkbox(
                    value: application.isApplied,
                    onChanged: (value) {
                      // TODO: 지원 완료 상태 변경 (추후 구현)
                    },
                    activeColor: AppColors.primary,
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
