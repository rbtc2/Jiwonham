// 요일 헤더 위젯
// 캘린더 상단에 요일을 표시하는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: day == '일'
                    ? AppColors.error
                    : day == '토'
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}




