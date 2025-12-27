# HomeScreen 리팩토링 계획

## 현재 상태 분석

### 문제점
- **단일 파일에 734줄**: 하나의 파일에 너무 많은 책임이 집중됨
- **높은 결합도**: UI, 비즈니스 로직, 데이터 계산이 모두 한 클래스에 존재
- **재사용성 낮음**: 섹션별 위젯들이 private 메서드로만 존재
- **테스트 어려움**: 모든 로직이 State 클래스에 결합되어 있음
- **코드 중복**: 날짜 포맷팅, 카드 스타일링 등이 반복됨
- **확장성 문제**: 새로운 기능 추가 시 파일이 계속 커질 수 있음

### 현재 구조
```
HomeScreen (734줄)
├── State 관리 (_applications, _isLoading)
├── 데이터 로드 (_loadApplications)
├── 비즈니스 로직
│   ├── 통계 계산 (_totalApplications, _inProgressCount, _passedCount)
│   ├── 마감 임박 공고 필터링 (_urgentApplications)
│   └── 오늘의 일정 계산 (_todaySchedules)
├── UI 빌드 메서드
│   ├── _buildStatisticsSection
│   ├── _buildStatCard
│   ├── _buildUrgentApplicationsSection
│   ├── _buildUrgentApplicationCard
│   ├── _buildTodayScheduleSection
│   └── _buildScheduleItem
└── 헬퍼 메서드
    ├── refresh
    ├── _refreshApplicationsScreen
    └── _showLinkErrorSnackBar
```

---

## 리팩토링 원칙

1. **점진적 리팩토링**: 한 번에 하나의 Phase씩 진행
2. **기능 유지**: 리팩토링 중에도 기존 기능은 정상 작동해야 함
3. **독립적 실행**: 각 Phase는 다른 Phase에 의존하지 않고 독립적으로 실행 가능
4. **테스트**: 각 Phase 완료 후 동작 확인
5. **일관성**: 기존 프로젝트 패턴(`ApplicationDetailViewModel`, `ApplicationsViewModel`)과 일치시키기
6. **문서화**: 변경사항 주석 및 문서 업데이트

---

## Phase 1: 통계 계산 로직 분리 (우선순위: 높음)

### 목표
- 통계 계산 로직을 별도 서비스/유틸리티로 분리
- 재사용성과 테스트 용이성 향상

### 작업 내용
1. **통계 계산 서비스 생성**
   - `lib/services/home_statistics_service.dart` 생성
   - 통계 계산 로직을 메서드로 추출

2. **분리할 로직**
   - 전체 공고 수 계산
   - 진행 중 공고 수 계산
   - 합격 공고 수 계산

3. **예상 효과**
   - 코드 가독성 향상
   - 테스트 가능한 로직 분리
   - 다른 화면에서도 재사용 가능

### 파일 구조
```dart
// lib/services/home_statistics_service.dart
class HomeStatisticsService {
  static int getTotalApplications(List<Application> applications) {
    return applications.length;
  }
  
  static int getInProgressCount(List<Application> applications) {
    return applications.where((app) => 
      app.status == ApplicationStatus.inProgress
    ).length;
  }
  
  static int getPassedCount(List<Application> applications) {
    return applications.where((app) => 
      app.status == ApplicationStatus.passed
    ).length;
  }
}
```

### 검증 체크리스트
- [ ] 통계 값이 기존과 동일하게 표시되는지 확인
- [ ] 서비스가 다른 곳에서도 사용 가능한지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 2: 마감 임박 공고 필터링 로직 분리 (우선순위: 높음)

### 목표
- 마감 임박 공고 필터링 로직을 별도 서비스로 분리
- 재사용성 향상

### 작업 내용
1. **필터링 서비스 생성**
   - `lib/services/urgent_applications_service.dart` 생성
   - 마감 임박 공고 필터링 및 정렬 로직 추출

2. **분리할 로직**
   - 마감 임박 공고 필터링 (D-3 이내)
   - 마감일 기준 정렬

3. **예상 효과**
   - 로직 재사용 가능
   - 테스트 용이성 향상
   - `UrgentApplicationsScreen`에서도 활용 가능

### 파일 구조
```dart
// lib/services/urgent_applications_service.dart
class UrgentApplicationsService {
  static List<Application> getUrgentApplications(
    List<Application> applications,
  ) {
    return applications
        .where((app) => app.isUrgent && !app.isDeadlinePassed)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }
}
```

### 검증 체크리스트
- [ ] 마감 임박 공고 목록이 기존과 동일하게 표시되는지 확인
- [ ] 정렬 순서가 올바른지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 3: 오늘의 일정 계산 로직 분리 (우선순위: 높음)

### 목표
- 오늘의 일정 계산 로직을 별도 서비스로 분리
- 복잡한 로직을 독립적으로 테스트 가능하게 만들기

### 작업 내용
1. **일정 계산 서비스 생성**
   - `lib/services/today_schedule_service.dart` 생성
   - 오늘의 일정 계산 로직 추출

2. **분리할 로직**
   - 마감일이 오늘인 경우
   - 발표일이 오늘인 경우
   - 다음 전형 일정이 오늘인 경우
   - 시간순 정렬

3. **예상 효과**
   - 복잡한 로직의 테스트 용이성 향상
   - 코드 가독성 향상
   - 재사용 가능

### 파일 구조
```dart
// lib/services/today_schedule_service.dart
class TodayScheduleService {
  static List<ScheduleItem> getTodaySchedules(
    List<Application> applications,
  ) {
    // 오늘의 일정 계산 로직
  }
}

class ScheduleItem {
  final String type;
  final IconData icon;
  final Color color;
  final String company;
  final String? position;
  final String? timeOrDday;
  final Application application;
}
```

### 검증 체크리스트
- [ ] 오늘의 일정이 기존과 동일하게 표시되는지 확인
- [ ] 정렬 순서가 올바른지 확인
- [ ] 모든 일정 타입이 올바르게 표시되는지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 4: 통계 섹션 위젯 분리 (우선순위: 중간)

### 목표
- 통계 섹션을 독립적인 위젯으로 분리
- 재사용성과 유지보수성 향상

### 작업 내용
1. **위젯 파일 생성**
   - `lib/screens/home/widgets/statistics_section.dart` 생성
   - `lib/screens/home/widgets/stat_card.dart` 생성

2. **분리할 위젯**
   - `_buildStatisticsSection` → `StatisticsSection`
   - `_buildStatCard` → `StatCard`

3. **예상 효과**
   - 파일 크기: ~734줄 → ~650줄 (약 84줄 감소)
   - 위젯 재사용 가능
   - 테스트 용이성 향상

### 파일 구조
```dart
// lib/screens/home/widgets/statistics_section.dart
class StatisticsSection extends StatelessWidget {
  final int totalApplications;
  final int inProgressCount;
  final int passedCount;
  
  // ...
}

// lib/screens/home/widgets/stat_card.dart
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  
  // ...
}
```

### 검증 체크리스트
- [ ] 통계 섹션이 기존과 동일하게 표시되는지 확인
- [ ] 스타일이 일치하는지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 5: 마감 임박 공고 섹션 위젯 분리 (우선순위: 중간)

### 목표
- 마감 임박 공고 섹션을 독립적인 위젯으로 분리
- 재사용성 향상

### 작업 내용
1. **위젯 파일 생성**
   - `lib/screens/home/widgets/urgent_applications_section.dart` 생성
   - `lib/screens/home/widgets/urgent_application_card.dart` 생성

2. **분리할 위젯**
   - `_buildUrgentApplicationsSection` → `UrgentApplicationsSection`
   - `_buildUrgentApplicationCard` → `UrgentApplicationCard`

3. **예상 효과**
   - 파일 크기: ~650줄 → ~500줄 (약 150줄 감소)
   - 위젯 재사용 가능
   - `UrgentApplicationsScreen`에서도 활용 가능

### 파일 구조
```dart
// lib/screens/home/widgets/urgent_applications_section.dart
class UrgentApplicationsSection extends StatelessWidget {
  final List<Application> urgentApplications;
  final VoidCallback? onViewAll;
  final Function(Application)? onApplicationTap;
  
  // ...
}

// lib/screens/home/widgets/urgent_application_card.dart
class UrgentApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  
  // ...
}
```

### 검증 체크리스트
- [ ] 마감 임박 공고 섹션이 기존과 동일하게 표시되는지 확인
- [ ] 카드 클릭 동작이 정상인지 확인
- [ ] 링크 열기 기능이 정상인지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 6: 오늘의 일정 섹션 위젯 분리 (우선순위: 중간)

### 목표
- 오늘의 일정 섹션을 독립적인 위젯으로 분리
- 재사용성 향상

### 작업 내용
1. **위젯 파일 생성**
   - `lib/screens/home/widgets/today_schedule_section.dart` 생성
   - `lib/screens/home/widgets/schedule_item.dart` 생성

2. **분리할 위젯**
   - `_buildTodayScheduleSection` → `TodayScheduleSection`
   - `_buildScheduleItem` → `ScheduleItem`

3. **예상 효과**
   - 파일 크기: ~500줄 → ~350줄 (약 150줄 감소)
   - 위젯 재사용 가능
   - 테스트 용이성 향상

### 파일 구조
```dart
// lib/screens/home/widgets/today_schedule_section.dart
class TodayScheduleSection extends StatelessWidget {
  final List<ScheduleItem> schedules;
  final Function(Application)? onScheduleTap;
  
  // ...
}

// lib/screens/home/widgets/schedule_item.dart
class ScheduleItemWidget extends StatelessWidget {
  final IconData icon;
  final String type;
  final String company;
  final String? timeOrDday;
  final Color color;
  final VoidCallback? onTap;
  
  // ...
}
```

### 검증 체크리스트
- [ ] 오늘의 일정 섹션이 기존과 동일하게 표시되는지 확인
- [ ] 일정 아이템 클릭 동작이 정상인지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 7: ViewModel 패턴 적용 (우선순위: 높음)

### 목표
- 상태 관리와 비즈니스 로직을 ViewModel로 분리
- 화면은 UI 렌더링에만 집중
- 기존 프로젝트 패턴과 일치시키기

### 작업 내용
1. **ViewModel 생성**
   - `lib/screens/home/home_view_model.dart` 생성
   - `ChangeNotifier` 기반으로 구현

2. **책임 분리**
   - **ViewModel**: 데이터 로드, 상태 관리, 통계/일정 계산
   - **Screen**: UI 렌더링, 사용자 입력 처리

3. **예상 효과**
   - 파일 크기: ~350줄 → ~200줄 (약 150줄 감소)
   - 비즈니스 로직 테스트 용이
   - UI와 로직의 명확한 분리
   - 상태 관리 일관성 향상

### ViewModel 구조
```dart
// lib/screens/home/home_view_model.dart
class HomeViewModel extends ChangeNotifier {
  List<Application> _applications = [];
  bool _isLoading = true;
  
  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  
  // 통계
  int get totalApplications => HomeStatisticsService.getTotalApplications(_applications);
  int get inProgressCount => HomeStatisticsService.getInProgressCount(_applications);
  int get passedCount => HomeStatisticsService.getPassedCount(_applications);
  
  // 마감 임박 공고
  List<Application> get urgentApplications => 
    UrgentApplicationsService.getUrgentApplications(_applications);
  
  // 오늘의 일정
  List<ScheduleItem> get todaySchedules => 
    TodayScheduleService.getTodaySchedules(_applications);
  
  Future<void> loadApplications() async { }
  void refresh() { }
}
```

### Screen 구조
```dart
// lib/screens/home/home_screen.dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadApplications();
  }
  
  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI만 담당
    );
  }
}
```

### 검증 체크리스트
- [ ] 모든 기능이 기존과 동일하게 작동하는지 확인
- [ ] 데이터 로드가 정상인지 확인
- [ ] 새로고침 기능이 정상인지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 8: 날짜 포맷팅 유틸리티 개선 (우선순위: 낮음)

### 목표
- 날짜 포맷팅 로직을 유틸리티로 통합
- 코드 중복 제거

### 작업 내용
1. **유틸리티 함수 추가**
   - `lib/utils/date_utils.dart`에 함수 추가
   - 마감일 포맷팅 함수 추가

2. **중복 코드 제거**
   - `_buildUrgentApplicationCard`의 날짜 포맷팅 로직을 유틸리티로 대체

3. **예상 효과**
   - 코드 중복 제거
   - 일관된 날짜 포맷팅
   - 유지보수성 향상

### 파일 구조
```dart
// lib/utils/date_utils.dart (기존 파일 확장)
String formatDeadline(DateTime deadline) {
  if (deadline.hour != 0 || deadline.minute != 0) {
    return '${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
  }
  return '${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')}';
}
```

### 검증 체크리스트
- [ ] 날짜 포맷이 기존과 동일한지 확인
- [ ] 시간이 있는 경우와 없는 경우 모두 올바르게 표시되는지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## Phase 9: 에러 처리 개선 (우선순위: 낮음)

### 목표
- 에러 처리 로직 개선
- 사용자에게 더 명확한 피드백 제공

### 작업 내용
1. **에러 상태 관리**
   - ViewModel에 에러 상태 추가
   - 에러 메시지 표시 UI 추가

2. **에러 처리 개선**
   - 데이터 로드 실패 시 에러 표시
   - 링크 열기 실패 시 에러 표시 개선

3. **예상 효과**
   - 사용자 경험 향상
   - 디버깅 용이성 향상

### 검증 체크리스트
- [ ] 에러 상황에서 적절한 메시지가 표시되는지 확인
- [ ] 에러 복구가 가능한지 확인
- [ ] 기존 기능에 영향 없음 확인

---

## 📊 최종 예상 구조

```
lib/screens/home/
├── home_screen.dart (~200줄)
│   └── UI 렌더링 및 ViewModel 연결만 담당
├── home_view_model.dart (~150줄)
│   └── 상태 관리 및 비즈니스 로직
└── widgets/
    ├── statistics_section.dart (~80줄)
    ├── stat_card.dart (~50줄)
    ├── urgent_applications_section.dart (~100줄)
    ├── urgent_application_card.dart (~120줄)
    ├── today_schedule_section.dart (~80줄)
    └── schedule_item.dart (~50줄)

lib/services/
├── home_statistics_service.dart (~50줄)
├── urgent_applications_service.dart (~30줄)
└── today_schedule_service.dart (~100줄)

lib/utils/
└── date_utils.dart (기존 파일 확장)
```

---

## 🚀 실행 순서 권장사항

### 우선순위 높음 (기능 향상)
1. **Phase 1**: 통계 계산 로직 분리
2. **Phase 2**: 마감 임박 공고 필터링 로직 분리
3. **Phase 3**: 오늘의 일정 계산 로직 분리
4. **Phase 7**: ViewModel 패턴 적용

### 우선순위 중간 (코드 구조 개선)
5. **Phase 4**: 통계 섹션 위젯 분리
6. **Phase 5**: 마감 임박 공고 섹션 위젯 분리
7. **Phase 6**: 오늘의 일정 섹션 위젯 분리

### 우선순위 낮음 (코드 품질 개선)
8. **Phase 8**: 날짜 포맷팅 유틸리티 개선
9. **Phase 9**: 에러 처리 개선

### 실행 가이드라인
1. **각 Phase 완료 후 테스트**: 기능이 정상 작동하는지 확인
2. **커밋 단위**: 각 Phase마다 커밋하여 롤백 가능하도록 유지
3. **점진적 진행**: 한 번에 모든 Phase를 진행하지 말고, 하나씩 완료
4. **독립적 실행**: 각 Phase는 다른 Phase에 의존하지 않으므로 순서 변경 가능

---

## ⚠️ 주의사항

1. **MainNavigation 연동**: 
   - `_refreshApplicationsScreen` 메서드가 `MainNavigationState`에 의존
   - ViewModel 패턴 적용 시 이 부분도 고려 필요

2. **기존 기능 유지**:
   - 새로고침 기능
   - 링크 열기 기능
   - 네비게이션 기능
   - 모든 기능이 리팩토링 후에도 정상 작동해야 함

3. **성능 고려**:
   - 통계/일정 계산이 빈번하게 호출되지 않도록 주의
   - ViewModel에서 적절한 캐싱 고려

4. **테스트**:
   - 각 Phase 완료 후 수동 테스트 필수
   - 특히 데이터 로드, 새로고침, 네비게이션 기능 확인

---

## 📝 추가 고려사항

### 상태 관리 라이브러리 도입 (선택사항)
현재는 `ChangeNotifier` 기반 ViewModel을 사용하지만, 향후 앱이 더 커질 경우:
- **Provider**: 간단하고 직관적
- **Riverpod**: 타입 안전성과 테스트 용이성
- **Bloc**: 복잡한 상태 관리에 적합

현재 단계에서는 ViewModel 패턴으로 충분하지만, 향후 확장 시 고려 가능

### 성능 최적화 (선택사항)
- 통계/일정 계산 결과 캐싱
- 불필요한 리빌드 방지 (`const` 위젯 활용)
- 리스트 렌더링 최적화

---

## ✅ 완료 체크리스트

각 Phase 완료 후 확인:
- [ ] 코드가 정상적으로 컴파일되는지 확인
- [ ] 기존 기능이 정상 작동하는지 확인
- [ ] 새로운 구조가 기존 패턴과 일치하는지 확인
- [ ] 주석 및 문서가 업데이트되었는지 확인
- [ ] 테스트가 완료되었는지 확인


