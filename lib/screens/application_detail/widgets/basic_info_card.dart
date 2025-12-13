// 기본 정보 카드 위젯
// 회사명, 직무명, D-Day 배지, 지원서 링크 버튼을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/application.dart';
import '../../../utils/url_utils.dart';
import '../../../widgets/d_day_badge.dart';

class BasicInfoCard extends StatelessWidget {
  final Application application;
  final Function(String) onLinkTap;

  const BasicInfoCard({
    super.key,
    required this.application,
    required this.onLinkTap,
  });

  Future<void> _openApplicationLink(String link) async {
    await openUrlOrThrow(link);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.companyName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (application.position != null &&
                          application.position!.isNotEmpty)
                        Text(
                          application.position!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
                DDayBadge(deadline: application.deadline),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: application.applicationLink != null
                  ? () async {
                      try {
                        await _openApplicationLink(
                          application.applicationLink!,
                        );
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
                    }
                  : null,
              icon: const Icon(Icons.link),
              label: const Text(AppStrings.openLink),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

