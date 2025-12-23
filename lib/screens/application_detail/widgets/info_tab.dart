// 정보 탭 위젯
// 기본 정보, 지원 정보, 메모를 표시하는 탭

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../models/application_status.dart';
import '../../../widgets/dialogs/status_change_dialog.dart';
import '../../../widgets/status_chip.dart';
import 'application_info_section.dart';
import 'basic_info_card.dart';
import 'memo_section.dart';
import 'preparation_checklist_section.dart';

class InfoTab extends StatelessWidget {
  final Application application;
  final Function(String) onLinkTap;
  final Function(String) onMemoUpdated;
  final Function(ApplicationStatus) onStatusChanged;
  final Function(int) onChecklistToggle;

  const InfoTab({
    super.key,
    required this.application,
    required this.onLinkTap,
    required this.onMemoUpdated,
    required this.onStatusChanged,
    required this.onChecklistToggle,
  });

  Future<void> _showStatusChangeDialog(BuildContext context) async {
    final result = await StatusChangeDialog.show(
      context,
      application.status,
    );
    if (result != null && result != application.status) {
      onStatusChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BasicInfoCard(
                  application: application,
                  onLinkTap: onLinkTap,
                ),
                const SizedBox(height: 12),
                ApplicationInfoSection(application: application),
                const SizedBox(height: 12),
                PreparationChecklistSection(
                  checklist: application.preparationChecklist,
                  onToggleCheck: onChecklistToggle,
                ),
                const SizedBox(height: 12),
                MemoSection(
                  application: application,
                  onMemoUpdated: onMemoUpdated,
                ),
                const SizedBox(height: 100), // 하단 버튼 공간
              ],
            ),
          ),
        ),
        // 하단 고정 버튼
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: () => _showStatusChangeDialog(context),
              icon: const Icon(Icons.swap_horiz),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.changeStatus),
                  const SizedBox(width: 8),
                  StatusChip(status: application.status),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}







