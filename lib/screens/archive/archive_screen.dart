// 보관함 화면
// 보관함에 저장된 공고들을 폴더별로 관리하는 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../models/application.dart';
import '../../models/archive_folder.dart';
import '../../services/storage_service.dart';
import '../../widgets/dialogs/multi_delete_confirm_dialog.dart';
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
  
  // 선택 모드 상태
  bool _isSelectionMode = false;
  Set<String> _selectedApplicationIds = {};
  
  // 복원/삭제 발생 여부 추적
  bool _hasRestoredOrDeleted = false;

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
      setState(() {
        _hasRestoredOrDeleted = true;
      });
      await _refreshData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보관함에서 복원되었습니다.')),
      );
    }
  }

  // 선택 모드 관리
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedApplicationIds.clear();
    });
  }

  // 항목 선택/해제
  void _toggleSelection(String applicationId) {
    setState(() {
      if (_selectedApplicationIds.contains(applicationId)) {
        _selectedApplicationIds.remove(applicationId);
        // 모든 선택 해제 시 선택 모드 비활성화
        if (_selectedApplicationIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedApplicationIds.add(applicationId);
        // 첫 번째 선택 시 선택 모드 활성화
        if (!_isSelectionMode) {
          _isSelectionMode = true;
        }
      }
    });
  }

  // 전체 선택/해제
  void _selectAll() {
    setState(() {
      _selectedApplicationIds = _filteredApplications.map((app) => app.id).toSet();
      if (_selectedApplicationIds.isNotEmpty) {
        _isSelectionMode = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedApplicationIds.clear();
      _isSelectionMode = false;
    });
  }

  // 선택된 공고 복원
  Future<void> _restoreSelectedApplications() async {
    if (_selectedApplicationIds.isEmpty) return;

    final selectedIds = List<String>.from(_selectedApplicationIds);
    final success = await _storageService.restoreApplicationsFromArchive(selectedIds);

    if (success && mounted) {
      setState(() {
        _hasRestoredOrDeleted = true;
      });
      _exitSelectionMode();
      await _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedIds.length}개의 공고가 복원되었습니다.')),
        );
      }
    }
  }

  // 선택된 공고 삭제
  Future<void> _deleteSelectedApplications() async {
    if (_selectedApplicationIds.isEmpty) return;

    final selectedCount = _selectedApplicationIds.length;
    final confirmed = await MultiDeleteConfirmDialog.show(
      context,
      selectedCount,
    );

    if (confirmed == true && mounted) {
      final selectedIds = List<String>.from(_selectedApplicationIds);
      int successCount = 0;
      int failCount = 0;

      for (final id in selectedIds) {
        final success = await _storageService.deleteApplication(id);
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (mounted) {
        if (successCount > 0) {
          setState(() {
            _hasRestoredOrDeleted = true;
          });
        }
        _exitSelectionMode();
        await _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failCount > 0
                    ? '$successCount개 삭제, $failCount개 실패'
                    : '$successCount개의 공고가 삭제되었습니다.',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasRestoredOrDeleted,
      onPopInvokedWithResult: (didPop, result) {
        // 뒤로 가기 시 복원/삭제가 발생했으면 공고 목록 화면에 알림
        if (!didPop && _hasRestoredOrDeleted) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSelectionMode
              ? Row(
                  key: const ValueKey('selection'),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedApplicationIds.length}개 선택됨',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                    ),
                  ],
                )
              : const Text('보관함'),
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
                tooltip: '선택 모드 종료',
              )
            : null,
        actions: _isSelectionMode
            ? [
                // 전체 선택/해제 버튼
                Builder(
                  builder: (context) {
                    final filteredApps = _filteredApplications;
                    final isAllSelected = filteredApps.isNotEmpty &&
                        _selectedApplicationIds.length == filteredApps.length;
                    final isEmpty = filteredApps.isEmpty;

                    return IconButton(
                      icon: Icon(
                        isAllSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      onPressed: isEmpty
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              if (isAllSelected) {
                                _deselectAll();
                              } else {
                                _selectAll();
                              }
                            },
                      tooltip: isEmpty
                          ? '선택할 항목이 없습니다'
                          : (isAllSelected ? '전체 해제' : '전체 선택'),
                    );
                  },
                ),
                // 복원 버튼
                if (_selectedApplicationIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: _restoreSelectedApplications,
                    tooltip: '복원',
                  ),
                // 삭제 버튼
                if (_selectedApplicationIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _deleteSelectedApplications,
                    tooltip: '삭제',
                  ),
              ]
            : [
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
                    isSelectionMode: _isSelectionMode,
                    selectedApplicationIds: _selectedApplicationIds,
                    onApplicationTap: (application) async {
                      if (!_isSelectionMode) {
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
                      }
                    },
                    onSelectionToggled: (applicationId) {
                      _toggleSelection(applicationId);
                      if (_selectedApplicationIds.contains(applicationId) &&
                          !_isSelectionMode) {
                        HapticFeedback.mediumImpact();
                      }
                    },
                    onLongPress: (applicationId) {
                      if (!_isSelectionMode) {
                        _toggleSelection(applicationId);
                        HapticFeedback.mediumImpact();
                      }
                    },
                    onRestore: _handleRestoreApplication,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

