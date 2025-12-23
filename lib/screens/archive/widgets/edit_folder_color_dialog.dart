// 폴더 색상 변경 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/archive_folder.dart';

class EditFolderColorDialog extends StatefulWidget {
  final ArchiveFolder folder;

  const EditFolderColorDialog({
    super.key,
    required this.folder,
  });

  @override
  State<EditFolderColorDialog> createState() => _EditFolderColorDialogState();
}

class _EditFolderColorDialogState extends State<EditFolderColorDialog> {
  late Color _selectedColor;
  
  final List<Color> _colorOptions = [
    AppColors.primary,
    const Color(0xFFF44336), // Red
    const Color(0xFF4CAF50), // Green
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFFEB3B), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = Color(widget.folder.color);
  }

  void _updateFolderColor() {
    if (_selectedColor.toARGB32() == widget.folder.color) {
      Navigator.pop(context);
      return;
    }

    final updatedFolder = widget.folder.copyWith(
      color: _selectedColor.toARGB32(),
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, updatedFolder);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('폴더 색상 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('폴더 색상을 선택하세요'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.textPrimary : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _updateFolderColor,
          child: const Text('변경'),
        ),
      ],
    );
  }
}

