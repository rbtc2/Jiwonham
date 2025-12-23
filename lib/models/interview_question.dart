// InterviewQuestion 모델
// 면접 질문 준비 정보를 담는 데이터 모델

class InterviewQuestion {
  final String id;
  final String question;  // 질문 내용
  final String? answer;   // 답변 (선택사항)

  InterviewQuestion({
    required this.id,
    required this.question,
    this.answer,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  // JSON 역직렬화
  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
    );
  }

  // 복사 생성자
  InterviewQuestion copyWith({
    String? id,
    String? question,
    String? answer,
  }) {
    return InterviewQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  // 답변 작성 여부
  bool get hasAnswer => answer != null && answer!.isNotEmpty;
}



