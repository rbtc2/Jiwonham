// 년/월 선택 위젯
// 캘린더에서 년도와 월을 선택할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class MonthYearPicker extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int year, int month) onSelected;

  const MonthYearPicker({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onSelected,
  });

  @override
  State<MonthYearPicker> createState() => MonthYearPickerState();
}

class MonthYearPickerState extends State<MonthYearPicker> {
  late int _selectedYear;
  late int _selectedMonth;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
    
    // 현재 년도와 월로 스크롤 위치 설정
    final currentYear = DateTime.now().year;
    final yearIndex = _selectedYear - currentYear + 5; // 현재 년도를 중앙에
    final monthIndex = _selectedMonth - 1;
    
    _yearController = FixedExtentScrollController(initialItem: yearIndex);
    _monthController = FixedExtentScrollController(initialItem: monthIndex);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  List<int> _generateYears() {
    final currentYear = DateTime.now().year;
    return List.generate(20, (index) => currentYear - 5 + index);
  }

  List<int> _generateMonths() {
    return List.generate(12, (index) => index + 1);
  }

  String _getMonthName(int month) {
    const months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final years = _generateYears();
    final months = _generateMonths();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 년도와 월 선택 영역
        Row(
          children: [
            // 년도 선택
            Expanded(
              child: Column(
                children: [
                  Text(
                    '년도',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListWheelScrollView.useDelegate(
                      controller: _yearController,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedYear = years[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final year = years[index];
                          final isSelected = year == _selectedYear;
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$year년',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: years.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // 월 선택
            Expanded(
              child: Column(
                children: [
                  Text(
                    '월',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListWheelScrollView.useDelegate(
                      controller: _monthController,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMonth = months[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final month = months[index];
                          final isSelected = month == _selectedMonth;
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getMonthName(month),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: months.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 선택된 날짜 미리보기
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$_selectedYear년 $_selectedMonth월',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void confirmSelection() {
    widget.onSelected(_selectedYear, _selectedMonth);
  }

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
}

