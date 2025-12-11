// 캘린더 화면
// 월간/주간/일간 뷰로 일정을 확인할 수 있는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../services/storage_service.dart';
import '../../widgets/calendar_event_marker.dart';
import '../application_detail/application_detail_screen.dart';

enum CalendarView { monthly, weekly, daily }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

// PHASE 3: State 클래스를 public으로 변경하여 외부에서 접근 가능하게 함
class CalendarScreenState extends State<CalendarScreen>
    with WidgetsBindingObserver {
  CalendarView _currentView = CalendarView.monthly;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  // 캘린더 이벤트 데이터 (날짜별로 그룹화)
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // PHASE 3: 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    _loadApplications();
  }

  @override
  void dispose() {
    // PHASE 3: 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // PHASE 3: 앱이 포그라운드로 돌아올 때 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 데이터 새로고침
      _loadApplications();
    }
  }

  // PHASE 3: 외부에서 호출 가능한 새로고침 메서드
  void refresh() {
    if (mounted) {
      _loadApplications();
    }
  }

  // PHASE 1: Application 데이터 로드
  // PHASE 4: 성능 최적화 - 불필요한 리빌드 방지
  Future<void> _loadApplications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();

      if (!mounted) return;

      // Application 데이터를 캘린더 이벤트로 변환
      final newEvents = _convertApplicationsToEvents(applications);

      if (!mounted) return;

      // PHASE 4: 이벤트가 변경된 경우에만 상태 업데이트
      setState(() {
        _events = newEvents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _events = {}; // 에러 발생 시 빈 맵
      });
    }
  }

  // PHASE 2: Application → 캘린더 이벤트 변환 (개선된 데이터 구조)
  Map<DateTime, List<Map<String, dynamic>>> _convertApplicationsToEvents(
    List<Application> applications,
  ) {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (final application in applications) {
      try {
        // 1. 서류 마감일 (deadline) 이벤트 추가
        // PHASE 5: 마감일이 지난 공고도 표시 (과거 일정 확인 가능)
        final deadlineDate = _getDateKey(application.deadline);
        events.putIfAbsent(deadlineDate, () => []).add({
          'type': 'deadline',
          'applicationId': application.id,
          'company': application.companyName,
          'position': application.position ?? '',
        });

        // 2. 서류 발표일 (announcementDate) 이벤트 추가
        if (application.announcementDate != null) {
          final announcementDate = _getDateKey(application.announcementDate!);
          events.putIfAbsent(announcementDate, () => []).add({
            'type': 'announcement',
            'applicationId': application.id,
            'company': application.companyName,
            'position': application.position ?? '',
          });
        }

        // 3. 면접 일정 (nextStages) 이벤트 추가
        for (final stage in application.nextStages) {
          final interviewDate = _getDateKey(stage.date);
          // 시간 정보 추출 (HH:mm 형식)
          final timeString = _formatTime(stage.date);
          events.putIfAbsent(interviewDate, () => []).add({
            'type': 'interview',
            'applicationId': application.id,
            'company': application.companyName,
            'position': application.position ?? '',
            'time': timeString,
            'stageType': stage.type,
          });
        }
      } catch (e) {
        // PHASE 5: 개별 Application 처리 중 에러 발생 시 해당 공고만 건너뛰고 계속 진행
        continue;
      }
    }

    return events;
  }

  // PHASE 1: 날짜 키 생성 (시간 제거, 년/월/일만 사용)
  DateTime _getDateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // PHASE 1: 시간 포맷팅 (HH:mm)
  // PHASE 5: null 안전성 개선
  String _formatTime(DateTime date) {
    try {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00'; // 에러 발생 시 기본값 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getMonthYearText()),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime.now();
                _selectedDate = DateTime.now();
              });
            },
            child: const Text(AppStrings.today),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(context)
          : _events.isEmpty
              ? _buildEmptyCalendarState(context)
              : Column(
                  children: [
                    // 뷰 전환 버튼
                    _buildViewToggle(context),
                    // 캘린더
                    Expanded(child: _buildCalendar(context)),
                    // 범례
                    _buildLegend(context),
                    // 선택된 날짜의 일정 목록
                    _buildScheduleList(context),
                  ],
                ),
    );
  }

  // PHASE 4: 로딩 상태 UI
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '일정을 불러오는 중...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // PHASE 4: 빈 캘린더 상태 UI (이벤트가 없을 때)
  Widget _buildEmptyCalendarState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 일정이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '공고를 추가하면 캘린더에 표시됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthYearText() {
    return '${_currentMonth.year}년 ${_currentMonth.month}월';
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildViewButton(context, AppStrings.monthly, CalendarView.monthly),
          _buildViewButton(context, AppStrings.weekly, CalendarView.weekly),
          _buildViewButton(context, AppStrings.daily, CalendarView.daily),
        ],
      ),
    );
  }

  Widget _buildViewButton(
    BuildContext context,
    String label,
    CalendarView view,
  ) {
    final isSelected = _currentView == view;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _currentView = view;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
            foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
            elevation: isSelected ? 2 : 0,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    switch (_currentView) {
      case CalendarView.monthly:
        return _buildMonthlyCalendar(context);
      case CalendarView.weekly:
        return _buildWeeklyCalendar(context);
      case CalendarView.daily:
        return _buildDailyCalendar(context);
    }
  }

  Widget _buildMonthlyCalendar(BuildContext context) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday;
    final daysInMonth = lastDay.day;
    final totalDays = firstDayOfWeek - 1 + daysInMonth;
    final weeks = (totalDays / 7).ceil();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 요일 헤더
          _buildWeekdayHeader(context),
          const SizedBox(height: 8),
          // 캘린더 그리드
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: weeks * 7,
              itemBuilder: (context, index) {
                final dayOffset = index - (firstDayOfWeek - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  dayOffset + 1,
                );
                final isSelected = _isSameDay(date, _selectedDate);
                // PHASE 4: 성능 최적화 - 현재 시간을 한 번만 계산
                final now = DateTime.now();
                final isToday = _isSameDay(date, now);
                final events = _getEventsForDate(date);

                return _buildCalendarDay(
                  context,
                  date,
                  isSelected,
                  isToday,
                  events,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: day == '일'
                    ? AppColors.error
                    : day == '토'
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDay(
    BuildContext context,
    DateTime date,
    bool isSelected,
    bool isToday,
    List<Map<String, dynamic>> events,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : isToday
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.take(3).map((event) {
                  EventType type;
                  if (event['type'] == 'deadline') {
                    type = EventType.deadline;
                  } else if (event['type'] == 'announcement') {
                    type = EventType.announcement;
                  } else {
                    type = EventType.interview;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: CalendarEventMarker(type: type),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar(BuildContext context) {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday % 7),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildWeekdayHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: weekDays.map((date) {
                final isSelected = _isSameDay(date, _selectedDate);
                // PHASE 4: 성능 최적화 - 현재 시간을 한 번만 계산
                final now = DateTime.now();
                final isToday = _isSameDay(date, now);
                final events = _getEventsForDate(date);

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : isToday
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (events.isNotEmpty)
                            ...events.map((event) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: _buildEventChip(context, event),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCalendar(BuildContext context) {
    final events = _getEventsForDate(_selectedDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDayOfWeek(_selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noSchedule,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(context, events[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventChip(BuildContext context, Map<String, dynamic> event) {
    Color color;
    IconData icon;
    String label;

    if (event['type'] == 'deadline') {
      color = AppColors.error;
      icon = Icons.event_busy;
      label = AppStrings.deadlineEvent;
    } else if (event['type'] == 'announcement') {
      color = AppColors.info;
      icon = Icons.campaign;
      label = AppStrings.announcementEvent;
    } else {
      color = AppColors.warning;
      icon = Icons.phone_in_talk;
      label = AppStrings.interviewEvent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    Color color;
    IconData icon;
    String label;

    if (event['type'] == 'deadline') {
      color = AppColors.error;
      icon = Icons.event_busy;
      label = AppStrings.deadlineEvent;
    } else if (event['type'] == 'announcement') {
      color = AppColors.info;
      icon = Icons.campaign;
      label = AppStrings.announcementEvent;
    } else {
      color = AppColors.warning;
      icon = Icons.phone_in_talk;
      label = AppStrings.interviewEvent;
    }

    // PHASE 2: 면접 타입 정보 표시 개선
    final stageType = event['stageType'] as String?;
    final displayLabel = stageType != null && event['type'] == 'interview'
        ? '$label ($stageType)'
        : label;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          _getEventTitle(event),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(displayLabel),
        trailing: event['time'] != null
            ? Text(
                event['time'] as String,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              )
            : null,
        onTap: () => _handleEventTap(context, event),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(context, AppColors.error, AppStrings.deadlineEvent),
          const SizedBox(width: 16),
          _buildLegendItem(
            context,
            AppColors.info,
            AppStrings.announcementEvent,
          ),
          const SizedBox(width: 16),
          _buildLegendItem(
            context,
            AppColors.warning,
            AppStrings.interviewEvent,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildScheduleList(BuildContext context) {
    final events = _getEventsForDate(_selectedDate);
    final dayOfWeek = _getDayOfWeek(_selectedDate);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatDate(_selectedDate)} ($dayOfWeek)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.noSchedule,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildScheduleItem(context, events[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, Map<String, dynamic> event) {
    Color color;
    IconData icon;
    String label;

    if (event['type'] == 'deadline') {
      color = AppColors.error;
      icon = Icons.event_busy;
      label = AppStrings.deadlineEvent;
    } else if (event['type'] == 'announcement') {
      color = AppColors.info;
      icon = Icons.campaign;
      label = AppStrings.announcementEvent;
    } else {
      color = AppColors.warning;
      icon = Icons.phone_in_talk;
      label = AppStrings.interviewEvent;
    }

    // PHASE 2: 면접 타입 정보 표시 개선
    final stageType = event['stageType'] as String?;
    final displayLabel = stageType != null && event['type'] == 'interview'
        ? '$label ($stageType)'
        : label;

    return InkWell(
      onTap: () => _handleEventTap(context, event),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getEventTitle(event),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (event['time'] != null)
              Text(
                event['time'] as String,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  // PHASE 2: 날짜별 이벤트 조회 (개선된 날짜 비교)
  // PHASE 5: 동일 날짜의 이벤트 정렬 (마감일 > 발표일 > 면접 순서)
  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final key = _getDateKey(date);
    final events = _events[key] ?? [];
    
    // PHASE 5: 이벤트 타입별 우선순위로 정렬
    // deadline(1) > announcement(2) > interview(3)
    events.sort((a, b) {
      final typeOrder = {
        'deadline': 1,
        'announcement': 2,
        'interview': 3,
      };
      final aOrder = typeOrder[a['type']] ?? 99;
      final bOrder = typeOrder[b['type']] ?? 99;
      
      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      
      // 같은 타입이면 회사명으로 정렬
      final aCompany = a['company'] as String? ?? '';
      final bCompany = b['company'] as String? ?? '';
      return aCompany.compareTo(bCompany);
    });
    
    return events;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[date.weekday % 7];
  }

  // PHASE 2: 이벤트 제목 생성 (position이 null일 때 처리)
  String _getEventTitle(Map<String, dynamic> event) {
    final company = event['company'] as String? ?? '';
    final position = event['position'] as String?;
    
    if (position != null && position.isNotEmpty) {
      return '$company - $position';
    }
    return company;
  }

  // PHASE 2: 이벤트 탭 처리 (개선된 에러 처리)
  Future<void> _handleEventTap(
    BuildContext context,
    Map<String, dynamic> event,
  ) async {
    final applicationId = event['applicationId'] as String?;

    if (applicationId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공고 정보를 찾을 수 없습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final storageService = StorageService();
      final application = await storageService.getApplicationById(applicationId);

      if (application != null && mounted) {
        _navigateToApplicationDetail(application);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('공고 정보를 찾을 수 없습니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공고 정보를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ApplicationDetailScreen으로 이동
  void _navigateToApplicationDetail(Application application) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationDetailScreen(application: application),
      ),
    );
  }
}
