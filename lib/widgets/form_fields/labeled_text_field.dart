// 라벨이 있는 텍스트 입력 필드 위젯
// 재사용 가능한 텍스트 입력 필드 컴포넌트

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hintText;
  final String? errorText;
  final VoidCallback? onChanged;
  final int? maxLines;
  final String? subtitle;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.maxLines,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surface,
            errorText: errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          onChanged: (_) {
            onChanged?.call();
          },
        ),
      ],
    );
  }
}






