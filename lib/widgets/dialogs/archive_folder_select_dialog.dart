// 보관함 폴더 선택 다이얼로그

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/archive_folder.dart';
import '../../services/storage_service.dart';

class ArchiveFolderSelectDialog extends StatefulWidget {
  const ArchiveFolderSelectDialog({super.key});

  @override
  State<ArchiveFolderSelectDialog> createState() => _ArchiveFolderSelectDialogState();
}

class _ArchiveFolderSelectDialogState extends State<ArchiveFolderSelectDialog> {
  final StorageService _storageService = StorageService();
  List<ArchiveFolder> _folders = [];
  bool _isLoading = true;
  String? _selectedFolderId; // null이면 보관함 루트

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _storageService.getAllArchiveFolders();
    if (mounted) {
      setState(() {
        _folders = folders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('보관함으로 이동'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: RadioGroup<String?>(
                  groupValue: _selectedFolderId,
                  onChanged: (value) {
                    setState(() {
                      _selectedFolderId = value;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 보관함 루트 옵션
                      RadioListTile<String?>(
                        title: const Text('보관함 루트'),
                        subtitle: const Text('폴더 없이 보관함에 저장'),
                        value: null,
                        activeColor: AppColors.primary,
                      ),
                      const Divider(),
                      // 폴더 목록
                      if (_folders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '폴더가 없습니다.\n보관함 화면에서 폴더를 만들 수 있습니다.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        )
                      else
                        ..._folders.map((folder) {
                          return RadioListTile<String?>(
                            title: Tooltip(
                              message: folder.name.length > 20 ? folder.name : '', // 긴 이름만 툴팁 표시
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: Color(folder.color),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      folder.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            value: folder.id,
                            activeColor: AppColors.primary,
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // 취소 시 false 반환
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedFolderId), // 이동 시 선택된 폴더 ID 반환
          child: const Text('이동'),
        ),
      ],
    );
  }
}

