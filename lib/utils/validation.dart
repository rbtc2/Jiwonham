// 검증 유틸리티 함수
// 폼 입력값 검증을 위한 순수 함수들

/// URL 형식 검증
/// http:// 또는 https://로 시작하는지 확인
bool isValidUrl(String url) {
  if (url.trim().isEmpty) {
    return false;
  }

  // http:// 또는 https://로 시작하는지 확인
  final urlPattern = RegExp(r'^https?://.+', caseSensitive: false);

  return urlPattern.hasMatch(url.trim());
}

/// 회사명 검증
/// 빈 값인지 확인
String? validateCompanyName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '회사명을 입력해주세요.';
  }
  return null;
}

/// URL 검증
/// 선택 항목이지만 입력한 경우 URL 형식 검증
String? validateUrl(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null; // 선택 항목이므로 빈 값은 유효
  }

  if (!isValidUrl(url)) {
    return '올바른 URL 형식을 입력해주세요. (예: https://...)';
  }

  return null;
}

/// 마감일 검증
/// 필수 항목이므로 null이면 에러
String? validateDeadline(DateTime? deadline) {
  if (deadline == null) {
    return '서류 마감일을 선택해주세요.';
  }
  return null;
}

/// ApplicationFormValidationResult
/// 검증 결과를 담는 클래스
class ApplicationFormValidationResult {
  final bool isValid;
  final String? companyNameError;
  final String? applicationLinkError;
  final String? deadlineError;

  const ApplicationFormValidationResult({
    required this.isValid,
    this.companyNameError,
    this.applicationLinkError,
    this.deadlineError,
  });
}

/// ApplicationFormValidator
/// 전체 폼 검증을 수행하는 클래스
class ApplicationFormValidator {
  /// 필수 필드 검증
  static ApplicationFormValidationResult validateRequiredFields({
    required String? companyName,
    required String? applicationLink,
    required DateTime? deadline,
  }) {
    final companyNameError = validateCompanyName(companyName);
    final applicationLinkError = validateUrl(applicationLink);
    final deadlineError = validateDeadline(deadline);

    final isValid = companyNameError == null &&
        applicationLinkError == null &&
        deadlineError == null;

    return ApplicationFormValidationResult(
      isValid: isValid,
      companyNameError: companyNameError,
      applicationLinkError: applicationLinkError,
      deadlineError: deadlineError,
    );
  }
}






