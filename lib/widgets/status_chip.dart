// 상태 칩 위젯
// 공고 상태를 표시하는 칩 위젯

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/application_status.dart';

class StatusChip extends StatelessWidget {
  final ApplicationStatus status;

  const StatusChip({
    super.key,
    required this.status,
  });

  String _getStatusText() {
    switch (status) {
      case ApplicationStatus.notApplied:
        return '지원 전';
      case ApplicationStatus.applied:
        return '지원 완료';
      case ApplicationStatus.inProgress:
        return '진행중';
      case ApplicationStatus.passed:
        return '합격';
      case ApplicationStatus.rejected:
        return '불합격';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppColors.textSecondary;
      case ApplicationStatus.applied:
        return AppColors.primary;
      case ApplicationStatus.inProgress:
        return AppColors.warning;
      case ApplicationStatus.passed:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ApplicationStatus.notApplied:
        return Icons.radio_button_unchecked;
      case ApplicationStatus.applied:
        return Icons.check_circle_outline;
      case ApplicationStatus.inProgress:
        return Icons.hourglass_empty;
      case ApplicationStatus.passed:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
