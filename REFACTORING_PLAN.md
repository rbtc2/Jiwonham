# AddEditApplicationScreen 리팩토링 계획

## 현재 상태
- **파일 크기**: 2,072줄
- **주요 문제점**:
  - 단일 파일에 너무 많은 책임 (폼 필드, 다이얼로그, 검증, 저장 로직)
  - 재사용 불가능한 코드
  - 유지보수 어려움
  - 테스트 어려움

## Phase별 리팩토링 계획

### Phase 1: 폼 필드 위젯 분리 (우선순위: 높음)
**목표**: 재사용 가능한 폼 필드 위젯 생성

**작업 내용**:
1. `lib/widgets/form_fields/` 디렉토리 생성
2. 다음 위젯들 분리:
   - `LabeledTextField` - 텍스트 입력 필드 (회사명, 직무명, 메모)
   - `LinkTextField` - 링크 입력 필드 (링크 테스트 버튼 포함)
   - `DateTimeField` - 날짜/시간 선택 필드 (알림 설정 포함)

**예상 효과**: 약 400줄 감소

---

### Phase 2: 다이얼로그 위젯 분리 (우선순위: 높음)
**목표**: 다이얼로그를 독립적인 위젯으로 분리

**작업 내용**:
1. `lib/widgets/dialogs/` 디렉토리 생성
2. 다음 다이얼로그들 분리:
   - `AddStageDialog` - 일정 추가 다이얼로그
   - `EditStageDialog` - 일정 수정 다이얼로그
   - `DeleteStageConfirmDialog` - 일정 삭제 확인 다이얼로그
   - `AddQuestionDialog` - 문항 추가 다이얼로그
   - `EditQuestionDialog` - 문항 수정 다이얼로그
   - `DeleteQuestionConfirmDialog` - 문항 삭제 확인 다이얼로그
   - `NotificationSettingsDialog` - 알림 설정 다이얼로그

**예상 효과**: 약 600줄 감소

---

### Phase 3: 검증 로직 분리 (우선순위: 중간)
**목표**: 검증 로직을 별도 유틸리티로 분리

**작업 내용**:
1. `lib/utils/validation.dart` 생성
2. 다음 함수들 분리:
   - `validateCompanyName(String? value)` - 회사명 검증
   - `validateUrl(String? url)` - URL 검증
   - `validateDeadline(DateTime? deadline)` - 마감일 검증
   - `ApplicationFormValidator` 클래스 생성 (통합 검증)

**예상 효과**: 약 100줄 감소, 테스트 용이성 향상

---

### Phase 4: 날짜/시간 선택 위젯 분리 (우선순위: 중간)
**목표**: 날짜/시간 선택 로직을 재사용 가능한 위젯으로 분리

**작업 내용**:
1. `lib/widgets/date_time_picker/` 디렉토리 생성
2. 다음 위젯들 생성:
   - `DateTimePickerField` - 날짜/시간 선택 필드
   - `TimeToggleSwitch` - 시간 포함 토글 스위치
   - `NotificationIconButton` - 알림 설정 아이콘 버튼

**예상 효과**: 약 200줄 감소

---

### Phase 5: 알림 설정 관련 로직 분리 (우선순위: 낮음)
**목표**: 알림 설정 관련 헬퍼 메서드 분리

**작업 내용**:
1. `lib/utils/notification_helpers.dart` 생성
2. 다음 함수들 분리:
   - `getNotificationIcon(String type, NotificationSettings? settings)`
   - `getNotificationColor(String type, NotificationSettings? settings)`
   - `getNotificationTimingLabel(NotificationTiming timing)`

**예상 효과**: 약 50줄 감소

---

### Phase 6: 섹션별 위젯 분리 (우선순위: 중간)
**목표**: 큰 섹션들을 독립적인 위젯으로 분리

**작업 내용**:
1. `lib/widgets/application_form_sections/` 디렉토리 생성
2. 다음 위젯들 분리:
   - `RequiredFieldsSection` - 필수 입력 필드 섹션
   - `NextStagesSection` - 다음 전형 일정 섹션
   - `CoverLetterQuestionsSection` - 자기소개서 문항 섹션
   - `StageItemWidget` - 전형 일정 아이템
   - `QuestionItemWidget` - 문항 아이템

**예상 효과**: 약 500줄 감소

---

### Phase 7: 상태 관리 최적화 (우선순위: 낮음, 선택사항)
**목표**: 상태 관리를 더 효율적으로 개선

**작업 내용**:
1. Form 데이터를 별도 클래스로 관리 (`ApplicationFormData`)
2. 또는 Provider/Riverpod 같은 상태 관리 라이브러리 도입 검토
3. 컨트롤러 관리 최적화

**예상 효과**: 코드 가독성 향상, 상태 관리 명확화

---

## 예상 총 효과

| Phase | 예상 감소 줄 수 | 누적 감소 |
|-------|---------------|----------|
| Phase 1 | 400줄 | 400줄 |
| Phase 2 | 600줄 | 1,000줄 |
| Phase 3 | 100줄 | 1,100줄 |
| Phase 4 | 200줄 | 1,300줄 |
| Phase 5 | 50줄 | 1,350줄 |
| Phase 6 | 500줄 | 1,850줄 |
| **총계** | **1,850줄** | **최종: ~220줄** |

**최종 목표**: 메인 화면 파일을 약 200-300줄로 축소

---

## 리팩토링 순서 권장사항

### 1단계 (즉시 시작 가능)
- Phase 1: 폼 필드 위젯 분리
- Phase 2: 다이얼로그 위젯 분리

### 2단계 (1단계 완료 후)
- Phase 3: 검증 로직 분리
- Phase 4: 날짜/시간 선택 위젯 분리

### 3단계 (2단계 완료 후)
- Phase 6: 섹션별 위젯 분리
- Phase 5: 알림 설정 관련 로직 분리

### 4단계 (선택사항)
- Phase 7: 상태 관리 최적화

---

## 주의사항

1. **각 Phase는 독립적으로 테스트 가능해야 함**
2. **기존 기능이 깨지지 않도록 주의**
3. **한 번에 하나의 Phase만 진행**
4. **각 Phase 완료 후 커밋 권장**

---

## 리팩토링 후 기대 효과

1. ✅ **가독성 향상**: 메인 파일이 200-300줄로 축소
2. ✅ **재사용성 향상**: 위젯들을 다른 화면에서도 사용 가능
3. ✅ **유지보수성 향상**: 각 기능이 독립적인 파일로 분리
4. ✅ **테스트 용이성**: 각 위젯/로직을 독립적으로 테스트 가능
5. ✅ **확장성 향상**: 새로운 기능 추가가 용이

