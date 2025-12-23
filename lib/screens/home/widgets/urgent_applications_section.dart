// 마감 임박 공고 섹션 위젯
// 마감 임박 공고 목록을 표시하는 섹션 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import 'urgent_application_card.dart';

class UrgentApplicationsSection extends StatelessWidget {
  final List<Application> urgentApplications;
  final VoidCallback? onViewAll;
  final Function(Application)? onApplicationTap;
  final Function(Application)? onApply;
  final Function(Application)? onViewDetail;

  const UrgentApplicationsSection({
    super.key,
    required this.urgentApplications,
    this.onViewAll,
    this.onApplicationTap,
    this.onApply,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.urgentApplications,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(AppStrings.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.urgentApplicationsSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (urgentApplications.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '마감 임박 공고가 없습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...urgentApplications.take(5).map((app) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UrgentApplicationCard(
                application: app,
                onTap: onApplicationTap != null
                    ? () => onApplicationTap!(app)
                    : null,
                onApply: onApply != null ? () => onApply!(app) : null,
                onViewDetail:
                    onViewDetail != null ? () => onViewDetail!(app) : null,
              ),
            );
          }),
      ],
    );
  }
}

