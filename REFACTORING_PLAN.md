# ApplicationDetailScreen 리팩토링 계획

## 현재 상태 분석

### 문제점
- **단일 파일에 1407줄**: 하나의 파일에 너무 많은 책임이 집중됨
- **높은 결합도**: UI, 비즈니스 로직, 다이얼로그가 모두 한 클래스에 존재
- **재사용성 낮음**: 섹션별 위젯들이 private 메서드로만 존재
- **테스트 어려움**: 모든 로직이 State 클래스에 결합되어 있음
- **확장성 문제**: 새로운 기능 추가 시 파일이 계속 커질 수 있음

### 현재 구조
```
ApplicationDetailScreen (1407줄)
├── State 관리 (Application, TabController, _hasChanges)
├── 비즈니스 로직 (로드, 상태 업데이트, 링크 열기)
├── UI 빌드 메서드 (3개 탭 + 여러 섹션)
│   ├── _buildInfoTab
│   ├── _buildCoverLetterTab
│   ├── _buildInterviewReviewTab
│   ├── _buildBasicInfoCard
│   ├── _buildApplicationInfoSection
│   ├── _buildMemoSection
│   ├── _buildStatusSection
│   ├── _buildCoverLetterSection
│   ├── _buildInterviewReviewSection
│   └── 기타 헬퍼 위젯들
└── 다이얼로그 (4개)
    ├── _showDeleteConfirmDialog
    ├── _showCoverLetterDialog
    ├── _showInterviewReviewDialog
    └── _showMemoDialog
```

---

## Phase 1: 다이얼로그 분리 (우선순위: 높음)

### 목표
- 다이얼로그를 별도 파일로 분리하여 재사용성과 유지보수성 향상
- 기존 `lib/widgets/dialogs/` 패턴과 일치시키기

### 작업 내용
1. **다이얼로그 파일 생성**
   - `lib/widgets/dialogs/delete_application_confirm_dialog.dart`
   - `lib/widgets/dialogs/cover_letter_answer_dialog.dart`
   - `lib/widgets/dialogs/interview_review_dialog.dart`
   - `lib/widgets/dialogs/memo_edit_dialog.dart`

2. **예상 효과**
   - 파일 크기: ~1407줄 → ~1000줄 (약 400줄 감소)
   - 다이얼로그 재사용 가능
   - 테스트 용이성 향상

### 구현 예시 구조
```dart
// lib/widgets/dialogs/cover_letter_answer_dialog.dart
class CoverLetterAnswerDialog extends StatefulWidget {
  final String question;
  final String initialAnswer;
  final int maxLength;
  final Function(String) onSave;
  
  // ...
}
```

---

## Phase 2: 탭별 위젯 분리 (우선순위: 높음)

### 목표
- 각 탭의 내용을 독립적인 위젯으로 분리
- 섹션별 위젯을 재사용 가능한 컴포넌트로 추출

### 작업 내용
1. **탭 위젯 생성**
   - `lib/screens/application_detail/widgets/info_tab.dart`
   - `lib/screens/application_detail/widgets/cover_letter_tab.dart`
   - `lib/screens/application_detail/widgets/interview_review_tab.dart`

2. **섹션 위젯 생성**
   - `lib/screens/application_detail/widgets/basic_info_card.dart`
   - `lib/screens/application_detail/widgets/application_info_section.dart`
   - `lib/screens/application_detail/widgets/memo_section.dart`
   - `lib/screens/application_detail/widgets/status_section.dart`
   - `lib/screens/application_detail/widgets/cover_letter_section.dart`
   - `lib/screens/application_detail/widgets/interview_review_section.dart`
   - `lib/screens/application_detail/widgets/interview_review_item.dart`
   - `lib/screens/application_detail/widgets/question_item.dart`
   - `lib/screens/application_detail/widgets/info_row.dart`

3. **예상 효과**
   - 파일 크기: ~1000줄 → ~300줄 (메인 스크린만)
   - 각 위젯이 독립적으로 테스트 가능
   - 재사용성 대폭 향상

### 디렉토리 구조
```
lib/screens/application_detail/
├── application_detail_screen.dart (메인, ~300줄)
└── widgets/
    ├── info_tab.dart
    ├── cover_letter_tab.dart
    ├── interview_review_tab.dart
    ├── basic_info_card.dart
    ├── application_info_section.dart
    ├── memo_section.dart
    ├── status_section.dart
    ├── cover_letter_section.dart
    ├── interview_review_section.dart
    ├── interview_review_item.dart
    ├── question_item.dart
    └── info_row.dart
```

---

## Phase 3: 비즈니스 로직 분리 (우선순위: 중간)

### 목표
- 상태 관리와 비즈니스 로직을 ViewModel/Controller로 분리
- 화면은 UI 렌더링에만 집중

### 작업 내용
1. **ViewModel 생성**
   - `lib/screens/application_detail/application_detail_view_model.dart`
   - 또는 `lib/viewmodels/application_detail_view_model.dart` (프로젝트 구조에 따라)

2. **책임 분리**
   - **ViewModel**: 데이터 로드, 상태 업데이트, 변경사항 추적
   - **Screen**: UI 렌더링, 사용자 입력 처리

3. **예상 효과**
   - 비즈니스 로직 테스트 용이
   - UI와 로직의 명확한 분리
   - 상태 관리 일관성 향상

### ViewModel 구조 예시
```dart
class ApplicationDetailViewModel extends ChangeNotifier {
  Application _application;
  bool _hasChanges = false;
  
  Application get application => _application;
  bool get hasChanges => _hasChanges;
  
  Future<void> loadApplication(String id) async { }
  Future<void> updateStatus(ApplicationStatus status) async { }
  Future<void> saveCoverLetterAnswer(int index, String answer) async { }
  // ...
}
```

---

## Phase 4: 유틸리티 및 헬퍼 분리 (우선순위: 낮음)

### 목표
- 공통 유틸리티 함수들을 별도 파일로 분리
- 날짜 포맷팅, 링크 처리 등 재사용 가능한 로직 추출

### 작업 내용
1. **유틸리티 함수 분리**
   - `lib/utils/application_utils.dart` 또는 기존 `date_utils.dart` 확장
   - `_formatDate` → `formatApplicationDate`
   - `_openApplicationLink` → `openApplicationLink` (utils 또는 service로)

2. **예상 효과**
   - 코드 중복 제거
   - 일관된 날짜 포맷팅
   - 유틸리티 함수 재사용

---

## Phase 5: 상태 관리 개선 (선택사항, 향후 확장 시)

### 목표
- 앱이 더 커질 경우를 대비한 상태 관리 라이브러리 도입 고려
- Provider, Riverpod, Bloc 등

### 고려 사항
- 현재는 StatefulWidget으로 충분할 수 있음
- 복잡도가 증가하면 도입 검토
- 팀의 선호도와 프로젝트 규모 고려

---

## 구현 우선순위 및 예상 시간

| Phase | 우선순위 | 예상 작업 시간 | 예상 효과 |
|-------|---------|--------------|----------|
| Phase 1 | 높음 | 2-3시간 | 파일 크기 30% 감소 |
| Phase 2 | 높음 | 4-6시간 | 파일 크기 80% 감소, 재사용성 향상 |
| Phase 3 | 중간 | 3-4시간 | 테스트 용이성, 유지보수성 향상 |
| Phase 4 | 낮음 | 1-2시간 | 코드 품질 향상 |
| Phase 5 | 선택 | - | 확장성 향상 |

**총 예상 시간**: 10-15시간 (Phase 1-4 기준)

---

## 리팩토링 후 예상 구조

```
lib/screens/application_detail/
├── application_detail_screen.dart (~300줄)
│   └── 탭 구조와 기본 레이아웃만 담당
├── application_detail_view_model.dart (~200줄)
│   └── 상태 관리 및 비즈니스 로직
└── widgets/
    ├── info_tab.dart (~150줄)
    ├── cover_letter_tab.dart (~100줄)
    ├── interview_review_tab.dart (~100줄)
    └── [섹션 위젯들] (~50-100줄 each)

lib/widgets/dialogs/
├── delete_application_confirm_dialog.dart
├── cover_letter_answer_dialog.dart
├── interview_review_dialog.dart
└── memo_edit_dialog.dart
```

---

## 리팩토링 원칙

1. **점진적 리팩토링**: 한 번에 하나의 Phase씩 진행
2. **기능 유지**: 리팩토링 중에도 기존 기능은 정상 작동해야 함
3. **테스트**: 각 Phase 완료 후 동작 확인
4. **일관성**: 기존 프로젝트 패턴과 일치시키기
5. **문서화**: 변경사항 주석 및 문서 업데이트

---

## 주의사항

- 리팩토링 전에 현재 기능이 정상 작동하는지 확인
- 각 Phase마다 커밋하여 롤백 가능하도록 유지
- 팀원과 협의 후 진행 (필요시)
- 성능 저하 없이 구조만 개선하는 것에 집중
