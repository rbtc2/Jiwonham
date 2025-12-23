// 검색 바 위젯
// 공고 목록에서 검색어를 입력하는 검색 바 위젯

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class ApplicationSearchBar extends StatefulWidget {
  final String initialQuery;
  final Function(String) onQueryChanged;

  const ApplicationSearchBar({
    super.key,
    required this.initialQuery,
    required this.onQueryChanged,
  });

  @override
  State<ApplicationSearchBar> createState() => _ApplicationSearchBarState();
}

class _ApplicationSearchBarState extends State<ApplicationSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: true,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: AppStrings.searchPlaceholder,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.7)
              : AppColors.textSecondary.withValues(alpha: 0.6),
        ),
      ),
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          widget.onQueryChanged(value.trim());
        });
      },
      onSubmitted: (value) {
        widget.onQueryChanged(value.trim());
      },
    );
  }
}







