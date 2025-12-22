# ApplicationsScreen 리팩토링 계획

## 현재 상태 분석

### 문제점
- **단일 파일에 1063줄**: 하나의 파일에 너무 많은 책임이 집중됨
- **높은 결합도**: UI, 비즈니스 로직, 필터링/정렬, 다이얼로그가 모두 한 클래스에 존재
- **복잡한 AppBar 로직**: 선택 모드, 검색 모드, 필터 상태가 혼재되어 가독성 저하
- **재사용성 낮음**: 필터 다이얼로그, 빈 목록 위젯 등이 private 메서드로만 존재
- **테스트 어려움**: 모든 로직이 State 클래스에 결합되어 있음
- **확장성 문제**: 새로운 기능 추가 시 파일이 계속 커질 수 있음

### 현재 구조
```
ApplicationsScreen (1063줄)
├── State 관리 (Applications, TabController, 필터/검색 상태, 선택 모드)
├── 비즈니스 로직 (로드, 삭제, 필터링, 정렬)
├── UI 빌드 메서드
│   ├── build (복잡한 AppBar 로직 포함)
│   ├── _buildTabBar
│   ├── _buildApplicationList
│   ├── _buildSearchBar
│   ├── _buildEmptyList
│   └── _buildActiveFiltersText
├── 필터링/정렬 로직
│   ├── _getFilteredApplications
│   ├── _sortApplications
│   └── _getCurrentStatus
└── 다이얼로그
    ├── _showFilterDialog
    └── _showMultiDeleteConfirmDialog
```

---

## Phase 1: 위젯 분리 (우선순위: 높음)

### 목표
- 복잡한 UI 컴포넌트를 독립적인 위젯으로 분리
- 재사용성과 유지보수성 향상

### 작업 내용
1. **AppBar 위젯 분리**
   - `lib/screens/applications/widgets/applications_app_bar.dart`
   - 선택 모드, 검색 모드, 필터 상태에 따른 AppBar 로직 분리

2. **필터 다이얼로그 분리**
   - `lib/widgets/dialogs/application_filter_dialog.dart`
   - 상태 필터, 마감일 필터를 포함한 재사용 가능한 다이얼로그

3. **빈 목록 위젯 분리**
   - `lib/screens/applications/widgets/empty_application_list.dart`
   - 필터 상태에 따른 빈 목록 메시지 표시

4. **검색 바 위젯 분리**
   - `lib/screens/applications/widgets/application_search_bar.dart`
   - 검색 입력 및 디바운스 로직 포함

5. **검색어 Chip 표시 위젯 분리**
   - `lib/screens/applications/widgets/search_query_chip.dart`
   - 검색어 표시 및 제거 기능

### 예상 효과
- 파일 크기: ~1063줄 → ~700줄 (약 35% 감소)
- 각 위젯이 독립적으로 테스트 가능
- 재사용성 대폭 향상

### 디렉토리 구조
```
lib/screens/applications/
├── applications_screen.dart (메인, ~700줄)
├── application_list_item.dart (기존)
└── widgets/
    ├── applications_app_bar.dart (~200줄)
    ├── application_search_bar.dart (~80줄)
    ├── search_query_chip.dart (~50줄)
    └── empty_application_list.dart (~80줄)

lib/widgets/dialogs/
├── application_filter_dialog.dart (~150줄)
└── multi_delete_confirm_dialog.dart (~80줄)
```

---

## Phase 2: ViewModel 패턴 적용 (우선순위: 높음)

### 목표
- 상태 관리와 비즈니스 로직을 ViewModel로 분리
- 화면은 UI 렌더링에만 집중
- 기존 `ApplicationDetailViewModel` 패턴과 일치

### 작업 내용
1. **ViewModel 생성**
   - `lib/screens/applications/applications_view_model.dart`
   - 또는 `lib/viewmodels/applications_view_model.dart` (프로젝트 구조에 따라)

2. **책임 분리**
   - **ViewModel**: 
     - 데이터 로드 (`_loadApplications`)
     - 필터링 로직 (`_getFilteredApplications`)
     - 정렬 로직 (`_sortApplications`)
     - 선택 모드 관리
     - 삭제 로직
   - **Screen**: 
     - UI 렌더링
     - 사용자 입력 처리
     - ViewModel과의 연결

3. **예상 효과**
   - 파일 크기: ~700줄 → ~400줄 (메인 스크린만)
   - 비즈니스 로직 테스트 용이
   - UI와 로직의 명확한 분리
   - 상태 관리 일관성 향상

### ViewModel 구조 예시
```dart
class ApplicationsViewModel extends ChangeNotifier {
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // 필터/검색 상태
  String _searchQuery = '';
  ApplicationStatus? _filterStatus;
  String? _deadlineFilter;
  String _sortBy = AppStrings.sortByDeadline;
  
  // 선택 모드
  bool _isSelectionMode = false;
  Set<String> _selectedApplicationIds = {};
  
  // Getters
  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  // ... 기타 getters
  
  // 메서드
  Future<void> loadApplications() async { }
  List<Application> getFilteredApplications(ApplicationStatus status) { }
  List<Application> sortApplications(List<Application> apps) { }
  Future<void> deleteSelectedApplications() async { }
  // ... 기타 메서드
}
```

---

## Phase 3: 필터/검색 로직 분리 (우선순위: 중간)

### 목표
- 필터링 및 검색 로직을 별도 서비스/유틸리티 클래스로 분리
- 재사용성 및 테스트 용이성 향상

### 작업 내용
1. **필터 서비스 생성**
   - `lib/services/application_filter_service.dart`
   - 필터링 로직 (`_getFilteredApplications`)
   - 정렬 로직 (`_sortApplications`)

2. **예상 효과**
   - 필터링 로직 재사용 가능
   - 단위 테스트 작성 용이
   - ViewModel 코드 간소화

### 서비스 구조 예시
```dart
class ApplicationFilterService {
  static List<Application> filterApplications({
    required List<Application> applications,
    String? searchQuery,
    ApplicationStatus? statusFilter,
    ApplicationStatus? tabStatus,
    String? deadlineFilter,
    String sortBy = AppStrings.sortByDeadline,
  }) {
    // 필터링 및 정렬 로직
  }
  
  static List<Application> sortApplications(
    List<Application> applications,
    String sortBy,
  ) {
    // 정렬 로직
  }
}
```

---

## Phase 4: 유틸리티 함수 분리 (우선순위: 낮음)

### 목표
- 헬퍼 메서드들을 별도 파일로 분리
- 재사용 가능한 유틸리티 함수 추출

### 작업 내용
1. **유틸리티 함수 분리**
   - `lib/utils/application_utils.dart`
   - `_getStatusText` → `getApplicationStatusText`
   - `_getSortByText` → `getSortByText`
   - `_buildActiveFiltersText` → `buildActiveFiltersText`

2. **예상 효과**
   - 코드 중복 제거
   - 일관된 텍스트 포맷팅
   - 유틸리티 함수 재사용

---

## 구현 우선순위 및 예상 시간

| Phase | 우선순위 | 예상 작업 시간 | 예상 효과 |
|-------|---------|--------------|----------|
| Phase 1 | 높음 | 3-4시간 | 파일 크기 35% 감소, 재사용성 향상 |
| Phase 2 | 높음 | 4-5시간 | 파일 크기 80% 감소, 테스트 용이성 향상 |
| Phase 3 | 중간 | 2-3시간 | 로직 재사용성 향상 |
| Phase 4 | 낮음 | 1-2시간 | 코드 품질 향상 |

**총 예상 시간**: 10-14시간 (Phase 1-4 기준)

---

## 리팩토링 후 예상 구조

```
lib/screens/applications/
├── applications_screen.dart (~400줄)
│   └── UI 렌더링 및 ViewModel 연결만 담당
├── applications_view_model.dart (~300줄)
│   └── 상태 관리 및 비즈니스 로직
├── application_list_item.dart (기존)
└── widgets/
    ├── applications_app_bar.dart (~200줄)
    ├── application_search_bar.dart (~80줄)
    ├── search_query_chip.dart (~50줄)
    └── empty_application_list.dart (~80줄)

lib/services/
└── application_filter_service.dart (~150줄)
    └── 필터링 및 정렬 로직

lib/widgets/dialogs/
├── application_filter_dialog.dart (~150줄)
└── multi_delete_confirm_dialog.dart (~80줄)

lib/utils/
└── application_utils.dart (~100줄)
    └── 헬퍼 함수들
```

---

## 리팩토링 원칙

1. **점진적 리팩토링**: 한 번에 하나의 Phase씩 진행
2. **기능 유지**: 리팩토링 중에도 기존 기능은 정상 작동해야 함
3. **테스트**: 각 Phase 완료 후 동작 확인
4. **일관성**: 기존 프로젝트 패턴(`ApplicationDetailViewModel`)과 일치시키기
5. **문서화**: 변경사항 주석 및 문서 업데이트

---

## 주의사항

- 리팩토링 전에 현재 기능이 정상 작동하는지 확인
- 각 Phase마다 커밋하여 롤백 가능하도록 유지
- `MainNavigation`에서 `ApplicationsScreenState`에 접근하는 부분 확인 필요
  - ViewModel 패턴 적용 시 GlobalKey 사용 방식 변경 필요할 수 있음
- 성능 저하 없이 구조만 개선하는 것에 집중

---

## 추가 고려사항

### 상태 관리 라이브러리 도입 (선택사항)
현재는 `ChangeNotifier` 기반 ViewModel을 사용하지만, 향후 앱이 더 커질 경우:
- **Provider**: 간단하고 직관적
- **Riverpod**: 타입 안전성과 테스트 용이성
- **Bloc**: 복잡한 상태 관리에 적합

현재 단계에서는 ViewModel 패턴으로 충분하지만, 향후 확장 시 고려 가능




