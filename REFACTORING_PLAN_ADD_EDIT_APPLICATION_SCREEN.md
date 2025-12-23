# AddEditApplicationScreen 리팩토링 계획

## 현재 상태 분석
- **파일 크기**: 1,138줄
- **주요 문제점**:
  1. `_buildRequiredFields` 메서드가 260줄로 과도하게 길고 복잡함
  2. `_loadApplicationData` 메서드가 복잡함 (90줄)
  3. `_saveApplication` 메서드가 복잡함 (170줄)
  4. `_testLink` 메서드가 길고 반복적인 SnackBar 코드가 많음
  5. 다이얼로그 핸들러 메서드들이 반복적임
  6. DateTime 처리 로직이 반복적임
  7. SnackBar 코드가 반복적임

## 리팩토링 단계별 계획

### Phase 8: 필수 필드 섹션 위젯 분리
**목표**: `_buildRequiredFields` 메서드를 독립적인 위젯으로 분리

**작업 내용**:
- `lib/widgets/application_form_sections/required_fields_section.dart` 생성
- 필수 필드들을 하나의 위젯으로 통합
- 콜백을 통해 상태 업데이트 처리
- 예상 감소: ~260줄 → ~50줄 (위젯으로 이동)

**장점**:
- 화면 파일 크기 대폭 감소
- 필수 필드 섹션 재사용 가능
- 테스트 용이성 향상

---

### Phase 9: Application 데이터 변환 로직 분리
**목표**: `_loadApplicationData`와 `_saveApplication`의 변환 로직을 별도 서비스로 분리

**작업 내용**:
- `lib/services/application_form_converter.dart` 생성
- `ApplicationFormData.fromApplication(Application)` 정적 메서드 추가
- `ApplicationFormData.toApplication()` 메서드 추가
- 알림 설정 통합 로직 분리
- NextStage 변환 로직 분리
- URL 처리 로직 분리

**예상 감소**: ~90줄 (변환 로직 분리)

**장점**:
- 비즈니스 로직과 UI 로직 분리
- 변환 로직 재사용 가능
- 테스트 용이성 향상

---

### Phase 10: SnackBar 유틸리티 분리
**목표**: 반복되는 SnackBar 코드를 재사용 가능한 유틸리티로 분리

**작업 내용**:
- `lib/utils/snackbar_utils.dart` 생성
- `showSuccessSnackBar`, `showErrorSnackBar`, `showInfoSnackBar` 메서드 추가
- 일관된 스타일 적용
- 모든 SnackBar 호출을 유틸리티로 교체

**예상 감소**: ~100줄 (반복 코드 제거)

**장점**:
- 코드 중복 제거
- 일관된 UI/UX
- 유지보수 용이성 향상

---

### Phase 11: 링크 테스트 기능 분리
**목표**: `_testLink` 메서드를 별도 서비스로 분리

**작업 내용**:
- `lib/services/link_test_service.dart` 생성
- URL 검증 및 처리 로직 분리
- 링크 열기 로직 분리
- 에러 처리 개선

**예상 감소**: ~130줄 (서비스로 이동)

**장점**:
- 책임 분리
- 재사용 가능성
- 테스트 용이성 향상

---

### Phase 12: 다이얼로그 핸들러 통합
**목표**: 반복되는 다이얼로그 핸들러 메서드들을 통합

**작업 내용**:
- 체크리스트, 스테이지, 문항 핸들러를 각각 하나의 클래스로 통합
- `lib/services/form_dialog_handlers.dart` 생성
- 또는 각 섹션 위젯에서 직접 처리하도록 개선

**예상 감소**: ~150줄 (핸들러 통합)

**장점**:
- 코드 중복 제거
- 유지보수 용이성 향상

---

### Phase 13: DateTime 처리 유틸리티 분리
**목표**: 반복되는 DateTime 처리 로직을 유틸리티로 분리

**작업 내용**:
- `lib/utils/date_time_form_utils.dart` 생성
- 시간 포함/제외 처리 로직 분리
- DateTime과 TimeOfDay 변환 로직 분리
- 반복되는 날짜/시간 처리 코드 제거

**예상 감소**: ~80줄 (반복 코드 제거)

**장점**:
- 코드 중복 제거
- 일관된 날짜/시간 처리
- 버그 감소

---

### Phase 14: 저장 로직 서비스 분리
**목표**: `_saveApplication` 메서드의 비즈니스 로직을 서비스로 분리

**작업 내용**:
- `lib/services/application_form_service.dart` 생성
- 저장 로직 분리
- 유효성 검사 통합
- 에러 처리 개선

**예상 감소**: ~170줄 (서비스로 이동)

**장점**:
- 비즈니스 로직과 UI 로직 분리
- 재사용 가능성
- 테스트 용이성 향상

---

## 예상 결과

### 파일 크기 감소
- **현재**: 1,138줄
- **예상**: ~300-400줄 (약 65-70% 감소)

### 개선 사항
1. ✅ 단일 책임 원칙 준수
2. ✅ 코드 재사용성 향상
3. ✅ 테스트 용이성 향상
4. ✅ 유지보수 용이성 향상
5. ✅ 성능 영향 없음 (로직 분리만 수행)

### 성능 고려사항
- 모든 리팩토링은 로직 분리만 수행하므로 성능 영향 없음
- 위젯 분리는 Flutter의 최적화된 빌드 시스템 활용
- 서비스 분리는 메모리 사용량에 영향 없음

---

## 실행 순서 권장사항

1. **Phase 8** (필수 필드 섹션 분리) - 가장 큰 영향
2. **Phase 9** (데이터 변환 로직 분리) - 핵심 로직 분리
3. **Phase 10** (SnackBar 유틸리티) - 빠른 개선
4. **Phase 11** (링크 테스트 분리) - 독립적인 기능
5. **Phase 12** (다이얼로그 핸들러 통합) - 중복 제거
6. **Phase 13** (DateTime 유틸리티) - 반복 코드 제거
7. **Phase 14** (저장 로직 서비스) - 마지막 정리

각 Phase는 독립적으로 실행 가능하며, 단계별로 테스트하여 안정성을 보장합니다.

