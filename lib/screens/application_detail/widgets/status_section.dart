// 상태 변경 섹션 위젯
// 지원 상태를 변경할 수 있는 라디오 버튼 그룹을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/application_status.dart';
import '../../../widgets/status_chip.dart';

class StatusSection extends StatelessWidget {
  final Application application;
  final Function(ApplicationStatus) onStatusChanged;

  const StatusSection({
    super.key,
    required this.application,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.changeStatus,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '지원 과정의 진행 상황을 추적합니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioGroup<ApplicationStatus>(
              groupValue: application.status,
              onChanged: (value) {
                if (value != null) {
                  onStatusChanged(value);
                }
              },
              child: Column(
                children: [
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.notApplied,
                    AppStrings.notAppliedStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.applied,
                    AppStrings.appliedStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.inProgress,
                    AppStrings.inProgressStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.passed,
                    AppStrings.passedStatus,
                  ),
                  _buildStatusRadio(
                    context,
                    ApplicationStatus.rejected,
                    AppStrings.rejectedStatus,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRadio(
    BuildContext context,
    ApplicationStatus status,
    String label,
  ) {
    return RadioListTile<ApplicationStatus>(
      title: Row(
        children: [
          StatusChip(status: status),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      value: status,
      contentPadding: EdgeInsets.zero,
    );
  }
}

