// ArchiveFolder 모델
// 보관함 폴더 정보를 담는 데이터 모델

class ArchiveFolder {
  final String id;
  final String name; // 폴더명
  final int color; // 폴더 색상 (ARGB 값)
  final int order; // 폴더 순서 (낮을수록 앞)
  final DateTime createdAt;
  final DateTime updatedAt;

  ArchiveFolder({
    required this.id,
    required this.name,
    this.color = 0xFF2196F3, // 기본 색상 (파란색)
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : order = order ?? 0,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory ArchiveFolder.fromJson(Map<String, dynamic> json) {
    return ArchiveFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as int? ?? 0xFF2196F3,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // 복사 생성자
  ArchiveFolder copyWith({
    String? id,
    String? name,
    int? color,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ArchiveFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

