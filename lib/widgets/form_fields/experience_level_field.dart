// 경력 수준 선택 필드 위젯
// 인턴/신입/경력직을 칩으로 선택할 수 있는 재사용 가능한 위젯

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/experience_level.dart';

class ExperienceLevelField extends StatelessWidget {
  final ExperienceLevel? selectedLevel;
  final Function(ExperienceLevel?) onChanged;

  const ExperienceLevelField({
    super.key,
    this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구분',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ExperienceLevel.values.map((level) {
            final isSelected = selectedLevel == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level != ExperienceLevel.values.last ? 8.0 : 0,
                ),
                child: ChoiceChip(
                  label: Text(level.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    onChanged(selected ? level : null);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

