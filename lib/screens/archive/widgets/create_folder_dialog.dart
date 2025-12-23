// 폴더 생성 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/archive_folder.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = AppColors.primary;
  
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
    // TextField 변경 감지를 위해 리스너 추가
    _nameController.addListener(() {
      setState(() {}); // 버튼 상태 업데이트
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createFolder() {
    final folder = ArchiveFolder(
      id: 'folder_${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.trim().hashCode}',
      name: _nameController.text.trim(),
      color: _selectedColor.toARGB32(),
    );
    Navigator.pop(context, folder);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 폴더 만들기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '폴더 이름',
              hintText: '폴더 이름을 입력하세요',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            maxLength: 20, // 최대 길이 제한
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              // Enter 키로도 만들기 가능
              if (_nameController.text.trim().isNotEmpty) {
                _createFolder();
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('폴더 색상'),
          const SizedBox(height: 8),
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
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : _createFolder,
          child: const Text('만들기'),
        ),
      ],
    );
  }
}

