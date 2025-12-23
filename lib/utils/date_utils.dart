// 날짜 유틸리티 함수
// - 날짜 포맷팅
// - 날짜 비교

/// 날짜를 YYYY.MM.DD 형식으로 포맷팅
String formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

/// 마감일을 포맷팅
/// 시간이 있으면 YYYY.MM.DD HH:mm 형식으로, 없으면 YYYY.MM.DD 형식으로 반환
String formatDeadline(DateTime deadline) {
  if (deadline.hour != 0 || deadline.minute != 0) {
    return '${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
  }
  return '${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')}';
}
