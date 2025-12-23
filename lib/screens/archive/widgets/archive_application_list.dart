// 보관함 공고 목록 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/application.dart';
import '../../applications/application_list_item.dart';

class ArchiveApplicationList extends StatelessWidget {
  final List<Application> applications;
  final bool isSelectionMode;
  final Set<String> selectedApplicationIds;
  final Function(Application) onApplicationTap;
  final Function(String) onSelectionToggled;
  final Function(String) onLongPress;
  final Function(String) onRestore;

  const ArchiveApplicationList({
    super.key,
    required this.applications,
    this.isSelectionMode = false,
    this.selectedApplicationIds = const {},
    required this.onApplicationTap,
    required this.onSelectionToggled,
    required this.onLongPress,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '보관함이 비어있습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 80, // 하단 네비게이션 바 높이 + safe area
      ),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        final isSelected = selectedApplicationIds.contains(application.id);
        
        Widget item = ApplicationListItem(
          application: application,
          isSelectionMode: isSelectionMode,
          isSelected: isSelected,
          onChanged: () {},
          onSelectionChanged: (selected) {
            onSelectionToggled(application.id);
          },
          onLongPress: () {
            onLongPress(application.id);
          },
        );

        // 선택 모드가 아닐 때만 스와이프로 복원 가능
        if (!isSelectionMode) {
          item = Dismissible(
            key: Key(application.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.restore,
                color: Colors.white,
                size: 32,
              ),
            ),
            onDismissed: (direction) {
              onRestore(application.id);
            },
            child: item,
          );
        }

        return item;
      },
    );
  }
}

