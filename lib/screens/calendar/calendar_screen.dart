// 캘린더 화면
// 월간/주간/일간 뷰로 일정을 확인할 수 있는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';
import '../../widgets/calendar_event_marker.dart';
import '../application_detail/application_detail_screen.dart';

enum CalendarView { monthly, weekly, daily }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarView _currentView = CalendarView.monthly;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  // 더미 일정 데이터
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2024, 1, 15): [
      {'type': 'deadline', 'company': '네이버', 'position': '백엔드 개발자'},
      {'type': 'deadline', 'company': '카카오', 'position': '프론트엔드 개발자'},
    ],
    DateTime(2024, 1, 18): [
      {
        'type': 'interview',
        'company': '삼성전자',
        'position': '소프트웨어 엔지니어',
        'time': '14:00',
      },
    ],
    DateTime(2024, 1, 25): [
      {'type': 'announcement', 'company': '네이버', 'position': '백엔드 개발자'},
    ],
  };

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
      body: Column(
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
                final isToday = _isSameDay(date, DateTime.now());
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
                final isToday = _isSameDay(date, DateTime.now());
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
          '${event['company']} - ${event['position']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(label),
        trailing: event['time'] != null
            ? Text(
                event['time'] as String,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              )
            : null,
        onTap: () async {
          // company와 position으로 Application 찾기
          final company = event['company'] as String;
          final position = event['position'] as String?;

          try {
            final storageService = StorageService();
            final applications = await storageService.getAllApplications();
            final application = applications.firstWhere(
              (app) =>
                  app.companyName == company &&
                  (position == null || app.position == position),
              orElse: () => Application(
                id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                companyName: company,
                position: position,
                applicationLink: null,
                deadline: DateTime.now(),
                status: ApplicationStatus.notApplied,
              ),
            );

            _navigateToApplicationDetail(application);
          } catch (e) {
            // 에러 발생 시 기본 Application 생성
            final defaultApplication = Application(
              id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
              companyName: company,
              position: position,
              applicationLink: null,
              deadline: DateTime.now(),
              status: ApplicationStatus.notApplied,
            );

            _navigateToApplicationDetail(defaultApplication);
          }
        },
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

    return Container(
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
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event['company']} - ${event['position']}',
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
    );
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _events[key] ?? [];
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
