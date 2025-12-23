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
import 'widgets/edit_folder_dialog.dart';
import 'widgets/edit_folder_color_dialog.dart';
import 'widgets/move_folder_dialog.dart';

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
  
  // 새로 생성된 폴더 ID 추적 (애니메이션용)
  String? _newlyCreatedFolderId;

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
      final allArchived = await _storageService.getAllArchivedApplications();
      
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
      // 전체 보관함: 모든 보관함 공고 표시 (폴더 구분 없이)
      apps = _archivedApplications.toList();
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
    // 다음 order 값 계산 (현재 폴더 개수)
    final nextOrder = _folders.length;
    
    final result = await showDialog<ArchiveFolder>(
      context: context,
      builder: (context) => CreateFolderDialog(nextOrder: nextOrder),
    );

    if (result != null) {
      final success = await _storageService.saveArchiveFolder(result);
      if (success && mounted) {
        await _refreshData();
        if (mounted) {
          // 새로 생성된 폴더를 자동으로 선택
          setState(() {
            _selectedFolderId = result.id;
            _newlyCreatedFolderId = result.id; // 애니메이션용
          });
          
          // 성공 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${result.name} 폴더가 생성되었습니다.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        // 실패 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('폴더 생성에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 폴더 옵션 Bottom Sheet 표시
  Future<void> _showFolderOptionsBottomSheet(ArchiveFolder folder) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들 바
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 폴더 이름 변경
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.primary),
                title: const Text('폴더 이름 변경'),
                onTap: () => Navigator.pop(context, 'rename'),
              ),
              // 구분선
              const Divider(height: 1),
              // 폴더 색상 변경
              ListTile(
                leading: Icon(Icons.palette_outlined, color: AppColors.primary),
                title: const Text('폴더 색상 변경'),
                onTap: () => Navigator.pop(context, 'changeColor'),
              ),
              // 구분선
              const Divider(height: 1),
              // 폴더 위치 변경
              ListTile(
                leading: Icon(Icons.swap_horiz, color: AppColors.primary),
                title: const Text('폴더 위치 변경'),
                onTap: () => Navigator.pop(context, 'movePosition'),
              ),
              // 구분선
              const Divider(height: 1),
              // 폴더 삭제
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  '폴더 삭제',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
              // 취소 버튼
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );

    if (result == 'rename') {
      await _renameFolder(folder);
    } else if (result == 'changeColor') {
      await _changeFolderColor(folder);
    } else if (result == 'movePosition') {
      await _moveFolderPosition(folder);
    } else if (result == 'delete') {
      await _deleteFolder(folder);
    }
  }

  // 폴더 이름 수정
  Future<void> _renameFolder(ArchiveFolder folder) async {
    final result = await showDialog<ArchiveFolder>(
      context: context,
      builder: (context) => EditFolderDialog(folder: folder),
    );

    if (result != null) {
      final success = await _storageService.saveArchiveFolder(result);
      if (success && mounted) {
        await _refreshData();
        if (mounted) {
          // 성공 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('폴더 이름이 "${result.name}"(으)로 변경되었습니다.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        // 실패 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('폴더 이름 변경에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 폴더 색상 변경
  Future<void> _changeFolderColor(ArchiveFolder folder) async {
    final result = await showDialog<ArchiveFolder>(
      context: context,
      builder: (context) => EditFolderColorDialog(folder: folder),
    );

    if (result != null) {
      final success = await _storageService.saveArchiveFolder(result);
      if (success && mounted) {
        await _refreshData();
        if (mounted) {
          // 성공 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('폴더 색상이 변경되었습니다.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        // 실패 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('폴더 색상 변경에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 폴더 위치 변경
  Future<void> _moveFolderPosition(ArchiveFolder folder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MoveFolderDialog(
        folder: folder,
        allFolders: _folders,
      ),
    );

    if (result == true && mounted) {
      await _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('폴더 위치가 변경되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
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

  // AppBar 타이틀 위젯 빌드 (브레드크럼 포함)
  Widget _buildTitleWidget() {
    if (_selectedFolderId == null) {
      // 전체 보관함
      return Row(
        key: const ValueKey('all'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.archive_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('보관함'),
        ],
      );
    } else {
      // 특정 폴더 선택
      final folder = _folders.firstWhere(
        (f) => f.id == _selectedFolderId,
        orElse: () => _folders.isNotEmpty ? _folders.first : ArchiveFolder(
          id: '',
          name: '',
        ),
      );

      // 폴더를 찾지 못한 경우 전체 보관함으로 표시
      if (folder.id.isEmpty) {
        return Row(
          key: const ValueKey('all'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.archive_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('보관함'),
          ],
        );
      }

      return Row(
        key: ValueKey('folder_${folder.id}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.archive_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('보관함'),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.folder,
            color: Color(folder.color),
            size: 20,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              folder.name,
              style: TextStyle(
                color: Color(folder.color),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
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
              : _buildTitleWidget(),
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
                tooltip: '선택 모드 종료',
              )
            : _selectedFolderId != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedFolderId = null;
                      });
                    },
                    tooltip: '전체 보관함으로',
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
                            name: '전체',
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
                        final isNewlyCreated = folder.id == _newlyCreatedFolderId;
                        return ArchiveFolderItem(
                          name: folder.name,
                          color: Color(folder.color),
                          isSelected: isSelected,
                          itemCount: folderApps,
                          isNewlyCreated: isNewlyCreated,
                          onTap: () {
                            setState(() {
                              _selectedFolderId = folder.id;
                              _newlyCreatedFolderId = null; // 선택 시 하이라이트 해제
                            });
                          },
                          onLongPress: () => _showFolderOptionsBottomSheet(folder),
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

