# CalendarScreen 리팩토링 계획

## 현재 상태 분석

### 문제점
- **단일 파일에 988줄**: 하나의 파일에 너무 많은 책임이 집중됨
- **높은 결합도**: UI, 비즈니스 로직, 데이터 변환이 모두 한 클래스에 존재
- **중복 코드**: 이벤트 타입별 색상/아이콘/라벨 결정 로직이 3곳 이상 반복됨
  - `_buildEventChip` (619-663줄)
  - `_buildEventCard` (665-715줄)
  - `_buildScheduleItem` (806-875줄)
- **재사용성 낮음**: 각 캘린더 뷰(월간/주간/일간)가 private 메서드로만 존재
- **테스트 어려움**: 모든 로직이 State 클래스에 결합되어 있음
- **확장성 문제**: 새로운 기능 추가 시 파일이 계속 커질 수 있음

### 현재 구조
```
CalendarScreen (988줄)
├── State 관리 (CalendarView, DateTime, Events Map, Loading)
├── 생명주기 관리 (WidgetsBindingObserver)
├── 데이터 로드 및 변환
│   ├── _loadApplications
│   └── _convertApplicationsToEvents
├── UI 빌드 메서드
│   ├── build (메인 레이아웃)
│   ├── _buildLoadingState
│   ├── _buildEmptyCalendarState
│   ├── _buildViewToggle
│   ├── _buildCalendar (switch로 뷰 선택)
│   ├── _buildMonthlyCalendar (~55줄)
│   ├── _buildWeeklyCalendar (~77줄)
│   ├── _buildDailyCalendar (~66줄)
│   ├── _buildEventChip
│   ├── _buildEventCard
│   ├── _buildScheduleList
│   ├── _buildScheduleItem
│   └── _buildLegend
└── 유틸리티 메서드
    ├── _getDateKey
    ├── _formatTime
    ├── _isSameDay
    ├── _formatDate
    ├── _getDayOfWeek
    ├── _getEventTitle
    └── _handleEventTap
```

### 다른 화면과의 비교
- `ApplicationDetailScreen`: 이미 리팩토링됨 (widgets/ 폴더, view_model 분리)
- `ApplicationsScreen`: 이미 리팩토링됨 (widgets/ 폴더, view_model 분리)
- `CalendarScreen`: **아직 리팩토링 필요** ❌

---

## Phase 1: 이벤트 스타일 유틸리티 분리 (우선순위: 높음)

### 목표
- 중복된 이벤트 타입별 스타일링 로직을 한 곳으로 통합
- 코드 중복 제거 및 유지보수성 향상

### 작업 내용
1. **이벤트 스타일 유틸리티 생성**
   - `lib/utils/calendar_event_style.dart`
   - 이벤트 타입별 색상, 아이콘, 라벨을 반환하는 클래스/함수

2. **예상 효과**
   - 중복 코드 약 150줄 제거
   - 이벤트 스타일 변경 시 한 곳만 수정하면 됨
   - 타입 안전성 향상

### 구현 예시 구조
```dart
// lib/utils/calendar_event_style.dart
class CalendarEventStyle {
  static Color getColor(String eventType) { ... }
  static IconData getIcon(String eventType) { ... }
  static String getLabel(String eventType) { ... }
}
```

---

## Phase 2: 캘린더 뷰 위젯 분리 (우선순위: 높음)

### 목표
- 월간/주간/일간 뷰를 독립적인 위젯으로 분리
- 재사용성과 테스트 용이성 향상

### 작업 내용
1. **캘린더 뷰 위젯 생성**
   - `lib/screens/calendar/widgets/monthly_calendar_view.dart`
   - `lib/screens/calendar/widgets/weekly_calendar_view.dart`
   - `lib/screens/calendar/widgets/daily_calendar_view.dart`

2. **예상 효과**
   - 파일 크기: ~988줄 → ~600줄 (약 400줄 감소)
   - 각 뷰가 독립적으로 테스트 가능
   - 새로운 뷰 타입 추가 시 확장 용이

### 디렉토리 구조
```
lib/screens/calendar/
├── calendar_screen.dart (~300줄, 메인 스크린)
├── calendar_view_model.dart (~200줄, 상태 관리)
└── widgets/
    ├── monthly_calendar_view.dart (~150줄)
    ├── weekly_calendar_view.dart (~120줄)
    ├── daily_calendar_view.dart (~100줄)
    ├── calendar_day_cell.dart (~80줄)
    ├── calendar_event_chip.dart (~50줄)
    ├── calendar_event_card.dart (~80줄)
    ├── calendar_schedule_list.dart (~100줄)
    └── calendar_legend.dart (~50줄)
```

---

## Phase 3: ViewModel 분리 (우선순위: 중간)

### 목표
- 비즈니스 로직과 상태 관리를 ViewModel로 분리
- 다른 화면들과 일관된 아키텍처 유지

### 작업 내용
1. **ViewModel 생성**
   - `lib/screens/calendar/calendar_view_model.dart`
   - 데이터 로드, 이벤트 변환 로직 이동
   - ChangeNotifier 패턴 사용 (다른 화면과 일관성)

2. **예상 효과**
   - 파일 크기: ~600줄 → ~300줄 (메인 스크린만)
   - 비즈니스 로직 테스트 용이
   - 상태 관리와 UI 분리

### 구현 예시 구조
```dart
// lib/screens/calendar/calendar_view_model.dart
class CalendarViewModel extends ChangeNotifier {
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;
  
  Future<void> loadApplications() async { ... }
  Map<DateTime, List<Map<String, dynamic>>> _convertApplicationsToEvents(...) { ... }
  List<Map<String, dynamic>> getEventsForDate(DateTime date) { ... }
}
```

---

## Phase 4: 이벤트 변환 서비스 분리 (우선순위: 낮음)

### 목표
- Application → Calendar Event 변환 로직을 별도 서비스로 분리
- 재사용성 향상

### 작업 내용
1. **서비스 생성**
   - `lib/services/calendar_event_service.dart`
   - `convertApplicationsToEvents` 메서드

2. **예상 효과**
   - 비즈니스 로직 재사용 가능
   - 테스트 용이성 향상

---

## Phase 5: 유틸리티 함수 분리 (우선순위: 낮음)

### 목표
- 날짜 관련 유틸리티 함수를 별도 파일로 분리
- 기존 `date_utils.dart`가 있다면 확장, 없다면 생성

### 작업 내용
1. **유틸리티 함수 분리**
   - `lib/utils/date_utils.dart` 또는 기존 파일 확장
   - `getDateKey`, `formatTime`, `isSameDay`, `formatDate`, `getDayOfWeek` 이동

2. **예상 효과**
   - 코드 재사용성 향상
   - 일관된 날짜 처리

---

## 구현 우선순위 및 예상 시간

| Phase | 우선순위 | 예상 작업 시간 | 예상 효과 |
|-------|---------|--------------|----------|
| Phase 1 | 높음 | 1-2시간 | 중복 코드 제거, 유지보수성 향상 |
| Phase 2 | 높음 | 4-6시간 | 파일 크기 40% 감소, 재사용성 향상 |
| Phase 3 | 중간 | 3-4시간 | 파일 크기 70% 감소, 테스트 용이성 향상 |
| Phase 4 | 낮음 | 2-3시간 | 비즈니스 로직 재사용성 향상 |
| Phase 5 | 낮음 | 1-2시간 | 코드 품질 향상 |

**총 예상 시간**: 11-17시간 (Phase 1-5 기준)

---

## 리팩토링 후 예상 구조

```
lib/screens/calendar/
├── calendar_screen.dart (~300줄)
│   └── 메인 레이아웃과 뷰 전환만 담당
├── calendar_view_model.dart (~200줄)
│   └── 상태 관리 및 데이터 로드
└── widgets/
    ├── monthly_calendar_view.dart (~150줄)
    ├── weekly_calendar_view.dart (~120줄)
    ├── daily_calendar_view.dart (~100줄)
    ├── calendar_day_cell.dart (~80줄)
    ├── calendar_event_chip.dart (~50줄)
    ├── calendar_event_card.dart (~80줄)
    ├── calendar_schedule_list.dart (~100줄)
    └── calendar_legend.dart (~50줄)

lib/utils/
├── calendar_event_style.dart (~50줄)
└── date_utils.dart (확장 또는 신규)

lib/services/
└── calendar_event_service.dart (~100줄)
```

---

## 주요 개선 사항 요약

1. **코드 중복 제거**: 이벤트 스타일 로직 통합
2. **모듈화**: 각 캘린더 뷰를 독립적인 위젯으로 분리
3. **아키텍처 일관성**: 다른 화면들과 동일한 ViewModel 패턴 적용
4. **테스트 용이성**: 각 컴포넌트를 독립적으로 테스트 가능
5. **확장성**: 새로운 기능 추가 시 영향 범위 최소화

---

## 결론

현재 988줄의 단일 파일은 **확장성과 유지보수성 측면에서 문제**가 있습니다. 특히:
- 다른 화면들(`ApplicationDetailScreen`, `ApplicationsScreen`)은 이미 리팩토링되어 있음
- 중복 코드가 많아 수정 시 여러 곳을 변경해야 함
- 새로운 기능 추가 시 파일이 계속 커질 수 있음

**권장 사항**: Phase 1-3을 우선적으로 진행하여 다른 화면들과 일관된 구조를 갖추는 것을 권장합니다.




