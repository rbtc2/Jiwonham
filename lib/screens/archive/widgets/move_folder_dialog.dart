// 폴더 위치 변경 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/archive_folder.dart';
import '../../../services/storage_service.dart';

class MoveFolderDialog extends StatelessWidget {
  final ArchiveFolder folder;
  final List<ArchiveFolder> allFolders;

  const MoveFolderDialog({
    super.key,
    required this.folder,
    required this.allFolders,
  });

  Future<void> _moveFolder(BuildContext context, bool moveLeft) async {
    final storageService = StorageService();
    final success = await storageService.moveFolderOrder(folder.id, moveLeft);
    
    if (context.mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              moveLeft 
                ? '이미 맨 앞에 있습니다.'
                : '이미 맨 뒤에 있습니다.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = allFolders.indexWhere((f) => f.id == folder.id);
    final canMoveLeft = currentIndex > 0;
    final canMoveRight = currentIndex < allFolders.length - 1;

    return AlertDialog(
      title: const Text('폴더 위치 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('폴더 위치를 변경하세요'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 좌측 이동 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canMoveLeft
                      ? () => _moveFolder(context, true)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('좌측 이동'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 우측 이동 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canMoveRight
                      ? () => _moveFolder(context, false)
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('우측 이동'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }
}

