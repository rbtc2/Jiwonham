// ModernBottomSheet 사용 예시
// 이 파일은 참고용 예시이며, 실제 사용 시 삭제해도 됩니다.

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'modern_bottom_sheet.dart';

/// 사용 예시 1: 간단한 텍스트 입력
class Example1_SimpleTextInput {
  static Future<void> showExample(BuildContext context) {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    return ModernBottomSheet.showInput<String>(
      context: context,
      title: '제목 입력',
      icon: Icons.edit,
      iconColor: AppColors.primary,
      inputField: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        maxLines: null,
        minLines: 6,
        decoration: InputDecoration(
          hintText: '내용을 입력하세요',
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
      confirmText: AppStrings.save,
      onConfirm: () {
        if (controller.text.trim().isNotEmpty) {
          Navigator.pop(context, controller.text.trim());
        }
      },
    ).then((_) {
      controller.dispose();
      focusNode.dispose();
    });
  }
}

/// 사용 예시 2: 커스텀 콘텐츠
class Example2_CustomContent {
  static Future<void> showExample(BuildContext context) {
    return ModernBottomSheet.showCustom(
      context: context,
      header: const ModernBottomSheetHeader(
        title: '커스텀 다이얼로그',
        icon: Icons.settings,
        iconColor: AppColors.primary,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('여기에 원하는 위젯을 넣을 수 있습니다.'),
          const SizedBox(height: 16),
          // 복잡한 폼이나 리스트 등
        ],
      ),
      actions: ModernBottomSheetActions(
        confirmText: '확인',
        onConfirm: () => Navigator.pop(context),
      ),
    );
  }
}

/// 사용 예시 3: 확인 다이얼로그
class Example3_ConfirmDialog {
  static Future<bool?> showExample(BuildContext context) {
    return ModernBottomSheet.showConfirm(
      context: context,
      title: '삭제 확인',
      message: '정말로 삭제하시겠습니까?',
      icon: Icons.warning,
      iconColor: AppColors.error,
      confirmText: AppStrings.delete,
      confirmButtonColor: AppColors.error,
    );
  }
}

/// 사용 예시 4: 직접 위젯 사용
class Example4_DirectWidget {
  static Future<void> showExample(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ModernBottomSheet(
          header: ModernBottomSheetHeader(
            title: '직접 사용',
            icon: Icons.info,
            iconColor: AppColors.info,
          ),
          content: Text('ModernBottomSheet 위젯을 직접 사용할 수도 있습니다.'),
          actions: ModernBottomSheetActions(
            confirmText: '확인',
          ),
        ),
      ),
    );
  }
}

