// URL 유틸리티 함수
// - URL 파싱 및 검증
// - 링크 열기

import 'package:url_launcher/url_launcher.dart';

/// URL 문자열을 Uri 객체로 변환
/// scheme이 없으면 https://를 추가합니다
Uri parseUrl(String urlString) {
  final uri = Uri.parse(urlString);
  if (!uri.hasScheme) {
    return Uri.parse('https://$urlString');
  }
  return uri;
}

/// URL을 외부 애플리케이션(브라우저)에서 엽니다
/// 
/// [urlString] 열 URL 문자열
/// 
/// 성공하면 true, 실패하면 false를 반환합니다
/// 예외가 발생하면 false를 반환합니다
Future<bool> openUrl(String urlString) async {
  try {
    final uri = parseUrl(urlString);
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    return false;
  }
}

/// URL을 외부 애플리케이션(브라우저)에서 엽니다
/// 예외를 throw할 수 있습니다
/// 
/// [urlString] 열 URL 문자열
/// 
/// 예외가 발생하면 rethrow합니다
Future<void> openUrlOrThrow(String urlString) async {
  final uri = parseUrl(urlString);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}




