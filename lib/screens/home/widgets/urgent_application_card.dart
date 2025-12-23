// 마감 임박 공고 카드 위젯
// 마감 임박 공고 정보를 표시하는 카드 위젯

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../widgets/d_day_badge.dart';
import '../../../utils/date_utils.dart';
import '../../application_detail/application_detail_screen.dart';
import '../../../utils/snackbar_utils.dart' as snackbar_utils;

class UrgentApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onViewDetail;

  const UrgentApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.onApply,
    this.onViewDetail,
  });

  Future<void> _handleApply(BuildContext context) async {
    if (onApply != null) {
      onApply!();
      return;
    }

    final link = application.applicationLink;
    if (link == null) return;

    try {
      Uri uri = Uri.parse(link);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$link');
      }
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        snackbar_utils.SnackBarUtils.showError(
          context,
          '링크를 열 수 없습니다: $e',
        );
      }
    }
  }

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetailScreen(application: application),
      ),
    );
  }

  void _handleViewDetail(BuildContext context) {
    if (onViewDetail != null) {
      onViewDetail!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetailScreen(application: application),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText = formatDeadline(application.deadline);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DDayBadge(deadline: application.deadline),
                  const Spacer(),
                  if (application.notificationSettings.deadlineNotification)
                    Icon(
                      Icons.notifications_active,
                      color: AppColors.warning,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (application.position != null &&
                  application.position!.isNotEmpty) ...[
                const SizedBox(height: 8),
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
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    deadlineText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (application.applicationLink != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleApply(context),
                        child: const Text(AppStrings.apply),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleViewDetail(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(AppStrings.viewDetail),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

