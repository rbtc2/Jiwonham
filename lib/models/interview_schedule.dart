// InterviewSchedule 모델
// 면접 일정 정보를 담는 데이터 모델

class InterviewSchedule {
  final DateTime? date;     // 면접 일시
  final String? location;    // 면접 장소

  InterviewSchedule({
    this.date,
    this.location,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'date': date?.toIso8601String(),
      'location': location,
    };
  }

  // JSON 역직렬화
  factory InterviewSchedule.fromJson(Map<String, dynamic> json) {
    return InterviewSchedule(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      location: json['location'] as String?,
    );
  }

  // 복사 생성자
  InterviewSchedule copyWith({
    DateTime? date,
    String? location,
  }) {
    return InterviewSchedule(
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }

  // 일정이 설정되어 있는지 확인
  bool get hasSchedule => date != null || (location != null && location!.isNotEmpty);
}




