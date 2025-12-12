// 날짜 유틸리티 함수
// - 날짜 포맷팅
// - 날짜 비교

String formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}
