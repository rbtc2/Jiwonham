// 폴더 생성 다이얼로그

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/archive_folder.dart';
import '../../../widgets/dialogs/modern_bottom_sheet.dart';

class CreateFolderDialog {
  // 폴더 이름 최소/최대 길이
  static const int minLength = 1;
  static const int maxLength = 20;

  // 금지된 특수문자 (파일시스템에서 문제가 될 수 있는 문자들)
  static final RegExp _invalidCharsRegex = RegExp(r'[<>:"/\\|?*\x00-\x1f]');

  // 유효성 검사 결과
  static String? _validateFolderName(
    String name,
    List<ArchiveFolder> existingFolders,
  ) {
    final trimmedName = name.trim();

    // 최소 길이 검증
    if (trimmedName.isEmpty) {
      return '폴더 이름을 입력해주세요.';
    }

    if (trimmedName.length < minLength) {
      return '폴더 이름은 최소 $minLength자 이상이어야 합니다.';
    }

    // 최대 길이 검증
    if (trimmedName.length > maxLength) {
      return '폴더 이름은 최대 $maxLength자까지 입력할 수 있습니다.';
    }

    // 특수문자 검증
    if (_invalidCharsRegex.hasMatch(trimmedName)) {
      return '사용할 수 없는 특수문자가 포함되어 있습니다.\n(< > : " / \\ | ? * 등)';
    }

    // 중복 검증
    final isDuplicate = existingFolders.any(
      (folder) => folder.name.trim().toLowerCase() == trimmedName.toLowerCase(),
    );
    if (isDuplicate) {
      return '이미 같은 이름의 폴더가 존재합니다.';
    }

    return null; // 유효함
  }

  static Future<ArchiveFolder?> show(
    BuildContext context,
    int? nextOrder, {
    List<ArchiveFolder> existingFolders = const [],
  }) {
    return showModalBottomSheet<ArchiveFolder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateFolderDialogContent(
        nextOrder: nextOrder,
        existingFolders: existingFolders,
      ),
    );
  }
}

class _CreateFolderDialogContent extends StatefulWidget {
  final int? nextOrder;
  final List<ArchiveFolder> existingFolders;

  const _CreateFolderDialogContent({
    required this.nextOrder,
    required this.existingFolders,
  });

  @override
  State<_CreateFolderDialogContent> createState() =>
      _CreateFolderDialogContentState();
}

class _CreateFolderDialogContentState
    extends State<_CreateFolderDialogContent> {
  late final TextEditingController _nameController;
  late final ValueNotifier<Color> _selectedColorNotifier;
  late final ValueNotifier<bool> _isValidNotifier;
  late final ValueNotifier<String?> _errorMessageNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  late final ValueNotifier<int> _textLengthNotifier;
  late final ValueNotifier<ModernBottomSheetActions> _actionsNotifier;
  late final FocusNode _focusNode;

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
    _nameController = TextEditingController();
    _selectedColorNotifier = ValueNotifier<Color>(AppColors.primary);
    _isValidNotifier = ValueNotifier<bool>(false);
    _errorMessageNotifier = ValueNotifier<String?>(null);
    _isLoadingNotifier = ValueNotifier<bool>(false);
    _textLengthNotifier = ValueNotifier<int>(0);
    _actionsNotifier = ValueNotifier<ModernBottomSheetActions>(
      ModernBottomSheetActions(
        cancelText: AppStrings.cancel,
        confirmText: '만들기',
        onCancel: () {
          Navigator.pop(context);
        },
        onConfirm: () async {
          await _handleCreate();
        },
        confirmButtonColor: AppColors.primary,
        confirmButtonEnabled: false,
      ),
    );
    _focusNode = FocusNode();

    // 이름 변경 감지
    _nameController.addListener(_validateInput);

    // 유효성 및 로딩 상태 변경 감지하여 actions 업데이트
    _isValidNotifier.addListener(_updateActions);
    _isLoadingNotifier.addListener(_updateActions);

    // 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _selectedColorNotifier.dispose();
    _isValidNotifier.dispose();
    _errorMessageNotifier.dispose();
    _isLoadingNotifier.dispose();
    _textLengthNotifier.dispose();
    _actionsNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateActions() {
    final isValid = _isValidNotifier.value;
    final isLoading = _isLoadingNotifier.value;
    _actionsNotifier.value = ModernBottomSheetActions(
      cancelText: AppStrings.cancel,
      confirmText: isLoading ? '생성 중...' : '만들기',
      onCancel: isLoading
          ? null
          : () {
              Navigator.pop(context);
            },
      onConfirm: (isValid && !isLoading)
          ? () async {
              await _handleCreate();
            }
          : null,
      confirmButtonColor: AppColors.primary,
      confirmButtonEnabled: isValid && !isLoading,
    );
  }

  void _validateInput() {
    final name = _nameController.text;
    _textLengthNotifier.value = name.length;
    final error = CreateFolderDialog._validateFolderName(
      name,
      widget.existingFolders,
    );
    _errorMessageNotifier.value = error;
    _isValidNotifier.value = error == null;
  }

  Future<void> _handleCreate() async {
    if (_isLoadingNotifier.value || !_isValidNotifier.value) return;

    _isLoadingNotifier.value = true;

    try {
      // 약간의 지연을 추가하여 로딩 상태를 시각적으로 표시
      await Future.delayed(const Duration(milliseconds: 300));

      final selectedColor = _selectedColorNotifier.value;
      final folder = ArchiveFolder(
        id: 'folder_${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.trim().hashCode}',
        name: _nameController.text.trim(),
        color: selectedColor.toARGB32(),
        order: widget.nextOrder ?? 0,
      );

      if (!mounted) return;

      Navigator.pop(context, folder);
    } catch (e) {
      _isLoadingNotifier.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('폴더 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom,
      ),
      child: ModernBottomSheet(
        header: const ModernBottomSheetHeader(
          title: '새 폴더 만들기',
          icon: Icons.create_new_folder_outlined,
          iconColor: AppColors.primary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 폴더 이름 입력
            ValueListenableBuilder<String?>(
              valueListenable: _errorMessageNotifier,
              builder: (context, errorMessage, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _textLengthNotifier,
                  builder: (context, textLength, _) {
                    return TextField(
                      controller: _nameController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        labelText: '폴더 이름',
                        hintText: '폴더 이름을 입력하세요',
                        errorText: errorMessage,
                        errorMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: errorMessage != null
                                ? AppColors.error
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: errorMessage != null
                                ? AppColors.error
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: errorMessage != null
                                ? AppColors.error
                                : AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        counterText:
                            '$textLength/${CreateFolderDialog.maxLength}',
                        counterStyle: TextStyle(
                          color: textLength > CreateFolderDialog.maxLength
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      autofocus: true,
                      maxLength: CreateFolderDialog.maxLength,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) async {
                        if (_isValidNotifier.value &&
                            !_isLoadingNotifier.value) {
                          await _handleCreate();
                        }
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // 폴더 색상 선택
            Text(
              '폴더 색상',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Color>(
              valueListenable: _selectedColorNotifier,
              builder: (context, selectedColor, _) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _colorOptions.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () {
                        _selectedColorNotifier.value = color;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 28,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        actionsNotifier: _actionsNotifier,
      ),
    );
  }
}
