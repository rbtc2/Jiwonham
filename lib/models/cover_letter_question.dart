// CoverLetterQuestion 모델
// 자기소개서 문항 정보를 담는 데이터 모델

class CoverLetterQuestion {
  final String question;  // 문항 내용
  final int maxLength;    // 최대 글자 수
  final String? answer;   // 답변 (선택사항)

  CoverLetterQuestion({
    required this.question,
    required this.maxLength,
    this.answer,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'maxLength': maxLength,
      'answer': answer,
    };
  }

  // JSON 역직렬화
  factory CoverLetterQuestion.fromJson(Map<String, dynamic> json) {
    return CoverLetterQuestion(
      question: json['question'] as String,
      maxLength: json['maxLength'] as int,
      answer: json['answer'] as String?,
    );
  }

  // 복사 생성자
  CoverLetterQuestion copyWith({
    String? question,
    int? maxLength,
    String? answer,
  }) {
    return CoverLetterQuestion(
      question: question ?? this.question,
      maxLength: maxLength ?? this.maxLength,
      answer: answer ?? this.answer,
    );
  }

  // 답변 글자 수
  int get answerLength => answer?.length ?? 0;

  // 답변 작성 여부
  bool get hasAnswer => answer != null && answer!.isNotEmpty;
}
