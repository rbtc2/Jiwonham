// 링크 입력 필드 위젯
// 링크 입력과 테스트 기능을 포함한 재사용 가능한 위젯

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class LinkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onChanged;
  final Future<void> Function(String url)? onTestLink;

  const LinkTextField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
    this.onTestLink,
  });

  Future<void> _handleTestLink(BuildContext context) async {
    final urlString = controller.text.trim();

    if (urlString.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('링크를 입력해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // 커스텀 핸들러가 있으면 사용
    if (onTestLink != null) {
      await onTestLink!(urlString);
      return;
    }

    // 기본 링크 테스트 로직
    Uri? uri;
    try {
      uri = Uri.parse(urlString);
      // http:// 또는 https://가 없으면 추가
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$urlString');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('올바른 URL 형식이 아닙니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // URL 열기
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('링크를 열 수 없습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크 열기 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              AppStrings.applicationLink,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  errorText: errorText,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) {
                  onChanged?.call();
                },
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                await _handleTestLink(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              child: const Text(AppStrings.testLink),
            ),
          ],
        ),
      ],
    );
  }
}








