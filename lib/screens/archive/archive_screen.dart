// 보관함 화면
// 보관함에 저장된 공고들을 폴더별로 관리하는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/application.dart';
import '../../models/archive_folder.dart';
import '../../services/storage_service.dart';
import '../application_detail/application_detail_screen.dart';
import 'widgets/archive_folder_item.dart';
import 'widgets/archive_application_list.dart';
import 'widgets/create_folder_dialog.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final StorageService _storageService = StorageService();
  List<ArchiveFolder> _folders = [];
  List<Application> _archivedApplications = [];
  bool _isLoading = true;
  String? _selectedFolderId; // null이면 전체 보관함
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final folders = await _storageService.getAllArchiveFolders();
      final allArchived = await _storageService.getArchivedApplications();
      
      if (!mounted) return;

      setState(() {
        _folders = folders;
        _archivedApplications = allArchived;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  List<Application> get _filteredApplications {
    List<Application> apps;
    
    if (_selectedFolderId == null) {
      // 전체 보관함: 폴더에 속하지 않은 공고만
      apps = _archivedApplications.where((app) => app.archiveFolderId == null).toList();
    } else {
      // 특정 폴더의 공고만
      apps = _archivedApplications.where((app) => app.archiveFolderId == _selectedFolderId).toList();
    }

    // 검색 필터링
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      apps = apps.where((app) {
        return app.companyName.toLowerCase().contains(query) ||
            (app.position?.toLowerCase().contains(query) ?? false) ||
            (app.memo?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return apps;
  }

  Future<void> _createFolder() async {
    final result = await showDialog<ArchiveFolder>(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );

    if (result != null) {
      final success = await _storageService.saveArchiveFolder(result);
      if (success && mounted) {
        await _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('폴더가 생성되었습니다.')),
          );
        }
      }
    }
  }

  Future<void> _deleteFolder(ArchiveFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('폴더 삭제'),
        content: Text('${folder.name} 폴더를 삭제하시겠습니까?\n폴더 안의 공고는 보관함 루트로 이동됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _storageService.deleteArchiveFolder(folder.id);
      if (success && mounted) {
        // 선택된 폴더가 삭제되면 전체 보관함으로 이동
        if (_selectedFolderId == folder.id) {
          setState(() {
            _selectedFolderId = null;
          });
        }
        await _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('폴더가 삭제되었습니다.')),
          );
        }
      }
    }
  }

  Future<void> _handleRestoreApplication(String applicationId) async {
    if (!mounted) return;
    final success = await _storageService.restoreApplicationFromArchive(applicationId);
    if (!mounted) return;
    if (success) {
      await _refreshData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보관함에서 복원되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보관함'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createFolder,
            tooltip: '폴더 만들기',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 폴더 목록
                if (_folders.isNotEmpty)
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _folders.length + 1, // +1 for "전체 보관함"
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 전체 보관함
                          final isSelected = _selectedFolderId == null;
                          return ArchiveFolderItem(
                            name: '전체 보관함',
                            color: AppColors.primary,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedFolderId = null;
                              });
                            },
                          );
                        }
                        final folder = _folders[index - 1];
                        final isSelected = _selectedFolderId == folder.id;
                        final folderApps = _archivedApplications
                            .where((app) => app.archiveFolderId == folder.id)
                            .length;
                        return ArchiveFolderItem(
                          name: folder.name,
                          color: Color(folder.color),
                          isSelected: isSelected,
                          itemCount: folderApps,
                          onTap: () {
                            setState(() {
                              _selectedFolderId = folder.id;
                            });
                          },
                          onLongPress: () => _deleteFolder(folder),
                        );
                      },
                    ),
                  ),
                // 검색 바
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '보관함에서 검색...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // 공고 목록
                Expanded(
                  child: ArchiveApplicationList(
                    applications: _filteredApplications,
                    onApplicationTap: (application) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ApplicationDetailScreen(application: application),
                        ),
                      );
                      if (result == true) {
                        await _refreshData();
                      }
                    },
                    onRestore: _handleRestoreApplication,
                  ),
                ),
              ],
            ),
    );
  }
}

