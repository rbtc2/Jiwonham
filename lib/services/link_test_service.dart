// LinkTestService
// 링크 테스트 및 URL 처리 로직을 담당하는 서비스

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/snackbar_utils.dart';

class LinkTestService {
  // URL 문자열을 Uri로 변환 (스킴이 없으면 자동으로 https:// 추가)
  static Uri? parseUrl(String urlString) {
    try {
      Uri uri = Uri.parse(urlString);
      // http:// 또는 https://가 없으면 추가
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$urlString');
      }
      return uri;
    } catch (e) {
      return null;
    }
  }

  // 링크 테스트 및 열기
  static Future<void> testAndOpenLink(
    BuildContext context,
    String urlString,
  ) async {
    // 빈 문자열 체크
    if (urlString.trim().isEmpty) {
      if (context.mounted) {
        SnackBarUtils.showError(context, '링크를 입력해주세요.');
      }
      return;
    }

    // URL 형식 검증 및 수정
    final uri = parseUrl(urlString.trim());
    if (uri == null) {
      if (context.mounted) {
        SnackBarUtils.showError(context, '올바른 URL 형식이 아닙니다.');
      }
      return;
    }

    // URL 열기 - LaunchMode.externalApplication을 사용하면 사용자가 브라우저를 선택할 수 있습니다
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        SnackBarUtils.showError(context, '링크를 열 수 없습니다.');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, '링크 열기 실패: $e');
      }
    }
  }
}

