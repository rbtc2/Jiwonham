// 폴더 위치 변경 다이얼로그

import 'package:flutter/material.dart';
import '../../../models/archive_folder.dart';

class MoveFolderDialog extends StatelessWidget {
  final ArchiveFolder folder;
  final List<ArchiveFolder> allFolders;

  const MoveFolderDialog({
    super.key,
    required this.folder,
    required this.allFolders,
  });

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
                child: OutlinedButton.icon(
                  onPressed: canMoveLeft
                      ? () => Navigator.pop(context, 'left')
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('좌측 이동'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 우측 이동 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canMoveRight
                      ? () => Navigator.pop(context, 'right')
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('우측 이동'),
                  style: OutlinedButton.styleFrom(
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

