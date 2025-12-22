// InterviewChecklist 모델
// 면접 체크리스트 정보를 담는 데이터 모델

class InterviewChecklist {
  final String id;
  final String item;     // 체크리스트 항목
  final bool isChecked;  // 체크 여부

  InterviewChecklist({
    required this.id,
    required this.item,
    this.isChecked = false,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'isChecked': isChecked,
    };
  }

  // JSON 역직렬화
  factory InterviewChecklist.fromJson(Map<String, dynamic> json) {
    return InterviewChecklist(
      id: json['id'] as String,
      item: json['item'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  // 복사 생성자
  InterviewChecklist copyWith({
    String? id,
    String? item,
    bool? isChecked,
  }) {
    return InterviewChecklist(
      id: id ?? this.id,
      item: item ?? this.item,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

