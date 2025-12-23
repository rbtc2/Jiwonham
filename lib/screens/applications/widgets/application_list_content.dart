// 공고 목록 콘텐츠 위젯
// 공고 목록을 ListView로 표시하는 위젯

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/application.dart';
import '../application_list_item.dart';

class ApplicationListContent extends StatelessWidget {
  final List<Application> applications;
  final bool isSelectionMode;
  final Set<String> selectedApplicationIds;
  final VoidCallback onApplicationChanged;
  final Function(String) onSelectionToggled;
  final Function(String) onLongPress;

  const ApplicationListContent({
    super.key,
    required this.applications,
    required this.isSelectionMode,
    required this.selectedApplicationIds,
    required this.onApplicationChanged,
    required this.onSelectionToggled,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: applications.length,
      // Phase 5: itemExtent 설정으로 성능 최적화 (선택사항)
      // itemExtent: 120, // 각 아이템의 예상 높이
      itemBuilder: (context, index) {
        final app = applications[index];
        return RepaintBoundary(
          child: ApplicationListItem(
          application: app,
          isSelectionMode: isSelectionMode,
          isSelected: selectedApplicationIds.contains(app.id),
          onChanged: onApplicationChanged,
          onSelectionChanged: (isSelected) {
            onSelectionToggled(app.id);
            if (isSelected && !isSelectionMode) {
              // 첫 번째 선택 시 햅틱 피드백
              HapticFeedback.mediumImpact();
            }
          },
          onLongPress: () {
            // 롱프레스 시 선택 모드 활성화 및 첫 항목 선택
            onLongPress(app.id);
            // 햅틱 피드백
            HapticFeedback.mediumImpact();
          },
          ),
        );
      },
    );
  }
}

