// ModernBottomSheet
// 재사용 가능한 모던 스타일의 Bottom Sheet 컴포넌트
// 앱 전체에서 일관된 디자인의 Bottom Sheet를 제공

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

/// 모던 Bottom Sheet의 헤더 정보
class ModernBottomSheetHeader {
  final String title;
  final IconData icon;
  final Color iconColor;

  const ModernBottomSheetHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });
}

/// 모던 Bottom Sheet의 버튼 정보
class ModernBottomSheetActions {
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Color? confirmButtonColor;
  final bool showCancelButton;
  final bool showConfirmButton;

  const ModernBottomSheetActions({
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.confirmButtonColor,
    this.showCancelButton = true,
    this.showConfirmButton = true,
  });
}

/// 모던 Bottom Sheet 위젯
class ModernBottomSheet extends StatelessWidget {
  final ModernBottomSheetHeader? header;
  final Widget content;
  final ModernBottomSheetActions? actions;
  final bool isScrollControlled;
  final double? maxHeight;

  const ModernBottomSheet({
    super.key,
    this.header,
    required this.content,
    this.actions,
    this.isScrollControlled = true,
    this.maxHeight,
  });

  /// 간단한 입력 다이얼로그 표시
  static Future<T?> showInput<T>({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget inputField,
    String? cancelText,
    String? confirmText,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ModernBottomSheet(
          header: ModernBottomSheetHeader(
            title: title,
            icon: icon,
            iconColor: iconColor,
          ),
          content: inputField,
          actions: ModernBottomSheetActions(
            cancelText: cancelText,
            confirmText: confirmText,
            onCancel: onCancel,
            onConfirm: onConfirm,
          ),
          isScrollControlled: isScrollControlled,
        ),
      ),
    );
  }

  /// 커스텀 콘텐츠 다이얼로그 표시
  static Future<T?> showCustom<T>({
    required BuildContext context,
    ModernBottomSheetHeader? header,
    required Widget content,
    ModernBottomSheetActions? actions,
    bool isScrollControlled = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ModernBottomSheet(
          header: header,
          content: content,
          actions: actions,
          isScrollControlled: isScrollControlled,
          maxHeight: maxHeight,
        ),
      ),
    );
  }

  /// 확인 다이얼로그 표시
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    String? cancelText,
    String? confirmText,
    Color? confirmButtonColor,
    VoidCallback? onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernBottomSheet(
        header: ModernBottomSheetHeader(
          title: title,
          icon: icon ?? Icons.info_outline,
          iconColor: iconColor ?? AppColors.info,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: ModernBottomSheetActions(
          cancelText: cancelText ?? AppStrings.cancel,
          confirmText: confirmText ?? AppStrings.confirm,
          onCancel: () => Navigator.pop(context, false),
          onConfirm: onConfirm ?? () => Navigator.pop(context, true),
          confirmButtonColor: confirmButtonColor,
        ),
        isScrollControlled: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget sheetContent = Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 헤더
            if (header != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: header!.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      header!.icon,
                      color: header!.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      header!.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            // 콘텐츠
            Flexible(
              child: SingleChildScrollView(
                child: content,
              ),
            ),
            // 액션 버튼
            if (actions != null) ...[
              const SizedBox(height: 24),
              _buildActions(context),
            ],
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
            ),
          ],
        ),
      ),
    );

    if (maxHeight != null) {
      sheetContent = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: sheetContent,
      );
    }

    return sheetContent;
  }

  Widget _buildActions(BuildContext context) {
    final actions = this.actions!;
    final hasBothButtons = actions.showCancelButton && actions.showConfirmButton;

    if (!actions.showCancelButton && !actions.showConfirmButton) {
      return const SizedBox.shrink();
    }

    if (!hasBothButtons) {
      // 버튼이 하나만 있는 경우
      if (actions.showConfirmButton) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: actions.onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: actions.confirmButtonColor ?? AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              actions.confirmText ?? AppStrings.save,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: actions.onCancel ?? () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              actions.cancelText ?? AppStrings.cancel,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }

    // 두 버튼 모두 있는 경우
    return Row(
      children: [
        if (actions.showCancelButton)
          Expanded(
            child: OutlinedButton(
              onPressed: actions.onCancel ?? () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actions.cancelText ?? AppStrings.cancel,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (actions.showCancelButton && actions.showConfirmButton)
          const SizedBox(width: 12),
        if (actions.showConfirmButton)
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: actions.onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: actions.confirmButtonColor ?? AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actions.confirmText ?? AppStrings.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

