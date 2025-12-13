# ApplicationsScreen 리팩토링 실행 PHASE

## 📋 전체 개요

**현재 상태**: 1063줄의 단일 파일  
**목표**: 약 400줄의 메인 파일 + 분리된 위젯 및 ViewModel  
**예상 시간**: 10-14시간  
**우선순위**: 높음 (앱 확장 전에 진행 권장)

---

## 🎯 PHASE 1: 다이얼로그 분리 (우선순위: 높음)

**예상 시간**: 2-3시간  
**예상 효과**: 파일 크기 약 200줄 감소

### 작업 단계

#### Step 1.1: 필터 다이얼로그 분리
- [ ] `lib/widgets/dialogs/application_filter_dialog.dart` 생성
- [ ] `_showFilterDialog` 메서드의 다이얼로그 로직 이동
- [ ] 필요한 파라미터 정의 (현재 필터 상태, 콜백 등)
- [ ] `applications_screen.dart`에서 새 다이얼로그 사용하도록 수정

**파일 구조**:
```dart
// lib/widgets/dialogs/application_filter_dialog.dart
class ApplicationFilterDialog extends StatefulWidget {
  final ApplicationStatus? initialStatusFilter;
  final String? initialDeadlineFilter;
  final Function(ApplicationStatus?, String?) onApply;
  
  // ...
}
```

#### Step 1.2: 다중 삭제 확인 다이얼로그 분리
- [ ] `lib/widgets/dialogs/multi_delete_confirm_dialog.dart` 생성
- [ ] `_showMultiDeleteConfirmDialog` 메서드의 다이얼로그 로직 이동
- [ ] 삭제 개수와 콜백 함수를 파라미터로 받도록 수정
- [ ] `applications_screen.dart`에서 새 다이얼로그 사용하도록 수정

**파일 구조**:
```dart
// lib/widgets/dialogs/multi_delete_confirm_dialog.dart
class MultiDeleteConfirmDialog extends StatelessWidget {
  final int count;
  final VoidCallback onConfirm;
  
  // ...
}
```

### 검증 체크리스트
- [ ] 필터 다이얼로그가 정상 작동하는지 확인
- [ ] 다중 삭제 다이얼로그가 정상 작동하는지 확인
- [ ] 기존 기능과 동일하게 동작하는지 확인

---

## 🎯 PHASE 2: 위젯 분리 (우선순위: 높음)

**예상 시간**: 3-4시간  
**예상 효과**: 파일 크기 약 300줄 추가 감소

### 작업 단계

#### Step 2.1: 디렉토리 구조 생성
- [ ] `lib/screens/applications/widgets/` 디렉토리 생성

#### Step 2.2: AppBar 위젯 분리
- [ ] `lib/screens/applications/widgets/applications_app_bar.dart` 생성
- [ ] `build` 메서드의 AppBar 로직 이동
- [ ] 필요한 상태 및 콜백을 파라미터로 전달
  - 선택 모드 상태
  - 검색 모드 상태
  - 검색 쿼리
  - 필터 상태
  - 정렬 상태
  - 각종 콜백 함수들

**파일 구조**:
```dart
// lib/screens/applications/widgets/applications_app_bar.dart
class ApplicationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final bool isSearchMode;
  final String searchQuery;
  final ApplicationStatus? filterStatus;
  final String? deadlineFilter;
  final String sortBy;
  final int selectedCount;
  final TabController tabController;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;
  final Function(String) onSortChanged;
  // ... 기타 콜백들
  
  // ...
}
```

#### Step 2.3: 검색 바 위젯 분리
- [ ] `lib/screens/applications/widgets/application_search_bar.dart` 생성
- [ ] `_buildSearchBar` 메서드 이동
- [ ] 검색 디바운스 로직 포함

**파일 구조**:
```dart
// lib/screens/applications/widgets/application_search_bar.dart
class ApplicationSearchBar extends StatefulWidget {
  final String initialQuery;
  final Function(String) onQueryChanged;
  
  // ...
}
```

#### Step 2.4: 검색어 Chip 위젯 분리
- [ ] `lib/screens/applications/widgets/search_query_chip.dart` 생성
- [ ] 검색어 표시 및 제거 기능 포함

**파일 구조**:
```dart
// lib/screens/applications/widgets/search_query_chip.dart
class SearchQueryChip extends StatelessWidget {
  final String query;
  final VoidCallback onDeleted;
  
  // ...
}
```

#### Step 2.5: 빈 목록 위젯 분리
- [ ] `lib/screens/applications/widgets/empty_application_list.dart` 생성
- [ ] `_buildEmptyList` 메서드 이동
- [ ] 필터 상태에 따른 메시지 표시 로직 포함

**파일 구조**:
```dart
// lib/screens/applications/widgets/empty_application_list.dart
class EmptyApplicationList extends StatelessWidget {
  final String tabName;
  final bool hasFilters;
  final VoidCallback onResetFilters;
  
  // ...
}
```

### 검증 체크리스트
- [ ] 각 위젯이 독립적으로 작동하는지 확인
- [ ] AppBar의 모든 기능이 정상 작동하는지 확인
- [ ] 검색 기능이 정상 작동하는지 확인
- [ ] 빈 목록 표시가 정상 작동하는지 확인

---

## 🎯 PHASE 3: ViewModel 패턴 적용 (우선순위: 높음)

**예상 시간**: 4-5시간  
**예상 효과**: 파일 크기 약 300줄 추가 감소, 테스트 용이성 향상

### 작업 단계

#### Step 3.1: ViewModel 클래스 생성
- [ ] `lib/screens/applications/applications_view_model.dart` 생성
- [ ] `ChangeNotifier` 상속
- [ ] 기존 상태 변수들을 ViewModel로 이동
  - `_applications`
  - `_isLoading`
  - `_errorMessage`
  - `_searchQuery`
  - `_filterStatus`
  - `_deadlineFilter`
  - `_sortBy`
  - `_isSelectionMode`
  - `_selectedApplicationIds`

#### Step 3.2: 비즈니스 로직 이동
- [ ] `_loadApplications` → `loadApplications` (public)
- [ ] `_getFilteredApplications` → `getFilteredApplications` (public)
- [ ] `_sortApplications` → `sortApplications` (public)
- [ ] `_deleteSelectedApplications` → `deleteSelectedApplications` (public)
- [ ] 선택 모드 관련 메서드들 이동

#### Step 3.3: Screen에서 ViewModel 사용
- [ ] `applications_screen.dart`에서 ViewModel 인스턴스 생성
- [ ] `ChangeNotifier` 리스너 등록
- [ ] UI에서 ViewModel의 상태 사용
- [ ] 콜백을 ViewModel 메서드 호출로 변경

#### Step 3.4: MainNavigation 수정
- [ ] `MainNavigation`에서 `GlobalKey<ApplicationsScreenState>` 사용 부분 확인
- [ ] ViewModel을 통한 새로고침 방식으로 변경 (필요시)
- [ ] 또는 ViewModel에 직접 접근하는 방식으로 변경

**파일 구조**:
```dart
// lib/screens/applications/applications_view_model.dart
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
  String? get errorMessage => _errorMessage;
  // ... 기타 getters
  
  // 메서드
  Future<void> loadApplications() async { }
  List<Application> getFilteredApplications(ApplicationStatus status) { }
  List<Application> sortApplications(List<Application> apps) { }
  Future<void> deleteSelectedApplications() async { }
  void toggleSelectionMode() { }
  void selectApplication(String id) { }
  // ... 기타 메서드
}
```

### 검증 체크리스트
- [ ] 데이터 로드가 정상 작동하는지 확인
- [ ] 필터링이 정상 작동하는지 확인
- [ ] 정렬이 정상 작동하는지 확인
- [ ] 선택 모드가 정상 작동하는지 확인
- [ ] 삭제 기능이 정상 작동하는지 확인
- [ ] 외부에서 새로고침 호출이 정상 작동하는지 확인

---

## 🎯 PHASE 4: 필터/검색 로직 분리 (우선순위: 중간)

**예상 시간**: 2-3시간  
**예상 효과**: 로직 재사용성 향상, 테스트 용이성 향상

### 작업 단계

#### Step 4.1: 필터 서비스 생성
- [ ] `lib/services/application_filter_service.dart` 생성
- [ ] `_getFilteredApplications` 로직을 static 메서드로 이동
- [ ] `_sortApplications` 로직을 static 메서드로 이동

#### Step 4.2: ViewModel에서 서비스 사용
- [ ] ViewModel에서 `ApplicationFilterService` 사용
- [ ] 필터링 및 정렬 로직을 서비스 메서드 호출로 변경

**파일 구조**:
```dart
// lib/services/application_filter_service.dart
class ApplicationFilterService {
  static List<Application> filterApplications({
    required List<Application> applications,
    String? searchQuery,
    ApplicationStatus? statusFilter,
    ApplicationStatus? tabStatus,
    String? deadlineFilter,
    String sortBy = AppStrings.sortByDeadline,
  }) {
    // 필터링 로직
  }
  
  static List<Application> sortApplications(
    List<Application> applications,
    String sortBy,
  ) {
    // 정렬 로직
  }
}
```

### 검증 체크리스트
- [ ] 필터링 결과가 기존과 동일한지 확인
- [ ] 정렬 결과가 기존과 동일한지 확인
- [ ] 서비스 메서드가 재사용 가능한지 확인

---

## 🎯 PHASE 5: 유틸리티 함수 분리 (우선순위: 낮음)

**예상 시간**: 1-2시간  
**예상 효과**: 코드 품질 향상, 재사용성 향상

### 작업 단계

#### Step 5.1: 유틸리티 파일 생성
- [ ] `lib/utils/application_utils.dart` 생성 (또는 기존 유틸리티 파일 확장)

#### Step 5.2: 헬퍼 메서드 이동
- [ ] `_getStatusText` → `getApplicationStatusText`
- [ ] `_getSortByText` → `getSortByText`
- [ ] `_buildActiveFiltersText` → `buildActiveFiltersText`
- [ ] `_getCurrentStatus` → `getCurrentTabStatus` (또는 ViewModel에 유지)

#### Step 5.3: 사용처 업데이트
- [ ] 모든 사용처에서 새 유틸리티 함수 사용

**파일 구조**:
```dart
// lib/utils/application_utils.dart
class ApplicationUtils {
  static String getApplicationStatusText(ApplicationStatus status) {
    // ...
  }
  
  static String getSortByText(String sortBy) {
    // ...
  }
  
  static String buildActiveFiltersText({
    String? searchQuery,
    ApplicationStatus? filterStatus,
    String? deadlineFilter,
  }) {
    // ...
  }
}
```

### 검증 체크리스트
- [ ] 모든 텍스트가 기존과 동일하게 표시되는지 확인
- [ ] 유틸리티 함수가 다른 곳에서도 사용 가능한지 확인

---

## 📊 최종 예상 구조

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

## 🚀 실행 순서 권장사항

1. **Phase 1부터 시작**: 다이얼로그 분리는 가장 안전하고 효과적
2. **각 Phase 완료 후 테스트**: 기능이 정상 작동하는지 확인
3. **커밋 단위**: 각 Phase마다 커밋하여 롤백 가능하도록 유지
4. **점진적 진행**: 한 번에 모든 Phase를 진행하지 말고, 하나씩 완료

---

## ⚠️ 주의사항

1. **MainNavigation 수정 필요**: 
   - `GlobalKey<ApplicationsScreenState>` 사용 부분 확인
   - ViewModel 패턴 적용 시 접근 방식 변경 필요할 수 있음

2. **기능 유지**: 
   - 리팩토링 중에도 모든 기능이 정상 작동해야 함
   - 각 Phase 완료 후 전체 기능 테스트

3. **일관성 유지**: 
   - 기존 `ApplicationDetailViewModel` 패턴과 일치시키기
   - 프로젝트의 네이밍 컨벤션 준수

---

## ✅ 완료 체크리스트

리팩토링 완료 후 확인할 사항:

- [ ] 모든 기능이 정상 작동함
- [ ] 파일 크기가 적절히 감소함 (메인 파일 ~400줄)
- [ ] 각 위젯이 독립적으로 테스트 가능함
- [ ] ViewModel이 비즈니스 로직을 담당함
- [ ] 코드 가독성이 향상됨
- [ ] 유지보수성이 향상됨
- [ ] 기존 기능과 동일하게 동작함

