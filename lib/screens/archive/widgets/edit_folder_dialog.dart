// 폴더 이름 수정 다이얼로그

import 'package:flutter/material.dart';
import '../../../models/archive_folder.dart';

class EditFolderDialog extends StatefulWidget {
  final ArchiveFolder folder;

  const EditFolderDialog({
    super.key,
    required this.folder,
  });

  @override
  State<EditFolderDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<EditFolderDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder.name);
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

  void _updateFolder() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.folder.name) {
      Navigator.pop(context);
      return;
    }

    final updatedFolder = widget.folder.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, updatedFolder);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('폴더 이름 변경'),
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
              // Enter 키로도 수정 가능
              if (_nameController.text.trim().isNotEmpty &&
                  _nameController.text.trim() != widget.folder.name) {
                _updateFolder();
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: (_nameController.text.trim().isEmpty ||
                  _nameController.text.trim() == widget.folder.name)
              ? null
              : _updateFolder,
          child: const Text('변경'),
        ),
      ],
    );
  }
}

