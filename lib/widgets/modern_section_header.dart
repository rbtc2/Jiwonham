// ModernSectionHeader 위젯
// 섹션 헤더를 표시하는 모던한 스타일의 위젯

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ModernSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const ModernSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
