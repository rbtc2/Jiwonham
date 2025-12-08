// NextStage 모델
// 다음 전형 일정 정보를 담는 데이터 모델

class NextStage {
  final String type;  // 전형 유형 (예: 면접, 최종 면접)
  final DateTime date; // 일정 날짜

  NextStage({
    required this.type,
    required this.date,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory NextStage.fromJson(Map<String, dynamic> json) {
    return NextStage(
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // 복사 생성자
  NextStage copyWith({
    String? type,
    DateTime? date,
  }) {
    return NextStage(
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}
