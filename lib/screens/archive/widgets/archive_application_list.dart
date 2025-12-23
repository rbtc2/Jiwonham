// 보관함 공고 목록 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/application.dart';
import '../../applications/application_list_item.dart';

class ArchiveApplicationList extends StatelessWidget {
  final List<Application> applications;
  final Function(Application) onApplicationTap;
  final Function(String) onRestore;

  const ArchiveApplicationList({
    super.key,
    required this.applications,
    required this.onApplicationTap,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return Dismissible(
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
          child: ApplicationListItem(
            application: application,
            onChanged: () {},
          ),
        );
      },
    );
  }
}

