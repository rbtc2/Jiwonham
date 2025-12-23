// ExperienceLevel enum
// 경력 수준을 나타내는 enum

enum ExperienceLevel {
  intern('인턴'),
  entry('신입'),
  experienced('경력직');

  final String label;
  const ExperienceLevel(this.label);
}

