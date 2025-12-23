// 년/월 선택 위젯
// 년도와 월을 선택할 수 있는 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class MonthYearPicker extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int year, int month)? onSelected;

  const MonthYearPicker({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    this.onSelected,
  });

  @override
  State<MonthYearPicker> createState() => MonthYearPickerState();
}

class MonthYearPickerState extends State<MonthYearPicker> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 년도 선택
        Text(
          '$_selectedYear년',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedYear--;
                });
                widget.onSelected?.call(_selectedYear, _selectedMonth);
              },
            ),
            SizedBox(
              width: 100,
              child: Text(
                '$_selectedYear년',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedYear++;
                });
                widget.onSelected?.call(_selectedYear, _selectedMonth);
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 월 선택
        Text(
          '$_selectedMonth월',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final isSelected = month == _selectedMonth;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedMonth = month;
                });
                widget.onSelected?.call(_selectedYear, _selectedMonth);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$month월',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
