// 지원 정보 섹션 위젯
// 서류 마감일, 발표일, 다음 전형 일정을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../utils/date_utils.dart';
import 'info_row.dart';

class ApplicationInfoSection extends StatelessWidget {
  final Application application;

  const ApplicationInfoSection({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지원 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            InfoRow(
              icon: Icons.calendar_today,
              label: '서류 마감일',
              value: formatDate(application.deadline),
              badge: 'D-${application.daysUntilDeadline}',
            ),
            if (application.announcementDate != null) ...[
              const Divider(height: 24),
              InfoRow(
                icon: Icons.campaign,
                label: '서류 발표일',
                value: formatDate(application.announcementDate!),
              ),
            ],
            if (application.nextStages.isNotEmpty) ...[
              const Divider(height: 24),
              ...application.nextStages.map((stage) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InfoRow(
                    icon: Icons.event,
                    label: stage.type,
                    value: formatDate(stage.date),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

