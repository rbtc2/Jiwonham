// 메모 편집 다이얼로그
// 공고에 대한 메모를 작성하거나 수정하는 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class MemoEditDialog extends StatefulWidget {
  final String? initialMemo;

  const MemoEditDialog({
    super.key,
    this.initialMemo,
  });

  static Future<String?> show(
    BuildContext context, {
    String? initialMemo,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => MemoEditDialog(initialMemo: initialMemo),
    );
  }

  @override
  State<MemoEditDialog> createState() => _MemoEditDialogState();
}

class _MemoEditDialogState extends State<MemoEditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMemo ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.editMemo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 입력 영역
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 15,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: '메모를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  style: const TextStyle(fontSize: 16),
                  autofocus: true,
                ),
              ),
            ),
            // 액션 버튼 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(AppStrings.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _controller.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(AppStrings.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


