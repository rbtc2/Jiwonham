// 보관함 폴더 아이템 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ArchiveFolderItem extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final int? itemCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ArchiveFolderItem({
    super.key,
    required this.name,
    required this.color,
    required this.isSelected,
    this.itemCount,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (itemCount != null && itemCount! > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$itemCount개',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

