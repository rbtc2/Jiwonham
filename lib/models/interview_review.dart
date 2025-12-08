// InterviewReview 모델
// 면접 후기 정보를 담는 데이터 모델

class InterviewReview {
  final String id;
  final DateTime date;           // 면접 일시
  final String type;              // 면접 유형 (예: 1차 면접, 2차 면접)
  final List<String> questions;   // 면접 질문 리스트
  final String review;           // 면접 후기
  final int rating;               // 평가 (1-5)

  InterviewReview({
    required this.id,
    required this.date,
    required this.type,
    required this.questions,
    required this.review,
    required this.rating,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'questions': questions,
      'review': review,
      'rating': rating,
    };
  }

  // JSON 역직렬화
  factory InterviewReview.fromJson(Map<String, dynamic> json) {
    return InterviewReview(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      questions: List<String>.from(json['questions'] as List),
      review: json['review'] as String,
      rating: json['rating'] as int,
    );
  }

  // 복사 생성자
  InterviewReview copyWith({
    String? id,
    DateTime? date,
    String? type,
    List<String>? questions,
    String? review,
    int? rating,
  }) {
    return InterviewReview(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      questions: questions ?? this.questions,
      review: review ?? this.review,
      rating: rating ?? this.rating,
    );
  }
}
