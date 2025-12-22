// 정보 탭 위젯
// 기본 정보, 지원 정보, 메모, 상태 변경을 표시하는 탭

import 'package:flutter/material.dart';
import '../../../models/application.dart';
import '../../../models/application_status.dart';
import 'application_info_section.dart';
import 'basic_info_card.dart';
import 'memo_section.dart';
import 'status_section.dart';

class InfoTab extends StatelessWidget {
  final Application application;
  final Function(String) onLinkTap;
  final Function(String) onMemoUpdated;
  final Function(ApplicationStatus) onStatusChanged;

  const InfoTab({
    super.key,
    required this.application,
    required this.onLinkTap,
    required this.onMemoUpdated,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const SizedBox(height: 16),
          ApplicationInfoSection(application: application),
          const SizedBox(height: 16),
          MemoSection(
            application: application,
            onMemoUpdated: onMemoUpdated,
          ),
          const SizedBox(height: 16),
          StatusSection(
            application: application,
            onStatusChanged: onStatusChanged,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}






