// 캘린더 화면
// 월간/주간 뷰로 일정을 확인할 수 있는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../services/storage_service.dart';
import '../application_detail/application_detail_screen.dart';
import 'calendar_view_model.dart';
import 'widgets/calendar_legend.dart';
import 'widgets/calendar_schedule_list.dart';
import 'widgets/monthly_calendar_view.dart';
import 'widgets/weekly_calendar_view.dart';

enum CalendarView { monthly, weekly }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

// PHASE 3: State 클래스를 public으로 변경하여 외부에서 접근 가능하게 함
class CalendarScreenState extends State<CalendarScreen>
    with WidgetsBindingObserver {
  late CalendarViewModel _viewModel;

  // UI 상태 (ViewModel에 포함되지 않는 UI 전용 상태)
  CalendarView _currentView = CalendarView.monthly;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarViewModel();
    _viewModel.addListener(_onViewModelChanged);
    // PHASE 3: 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    _viewModel.loadApplications();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    // PHASE 3: 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // PHASE 3: 앱이 포그라운드로 돌아올 때 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 데이터 새로고침
      _viewModel.loadApplications();
    }
  }

  // PHASE 3: 외부에서 호출 가능한 새로고침 메서드
  void refresh() {
    if (mounted) {
      _viewModel.loadApplications();
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
      body: _viewModel.isLoading
          ? _buildLoadingState(context)
          : !_viewModel.hasEvents
          ? _buildEmptyCalendarState(context)
          : Column(
              children: [
                // 뷰 전환 버튼
                _buildViewToggle(context),
                // 캘린더
                Expanded(child: _buildCalendar(context)),
                // 범례
                const CalendarLegend(),
                // 선택된 날짜의 일정 목록
                CalendarScheduleList(
                  selectedDate: _selectedDate,
                  events: _viewModel.getEventsForDate(_selectedDate),
                  getEventTitle: _viewModel.getEventTitle,
                  onEventTap: (event) => _handleEventTap(event),
                ),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '공고를 추가하면 캘린더에 표시됩니다',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        return MonthlyCalendarView(
          currentMonth: _currentMonth,
          selectedDate: _selectedDate,
          events: _viewModel.events,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          isSameDay: _viewModel.isSameDay,
          getEventsForDate: _viewModel.getEventsForDate,
        );
      case CalendarView.weekly:
        return WeeklyCalendarView(
          selectedDate: _selectedDate,
          events: _viewModel.events,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          isSameDay: _viewModel.isSameDay,
          getEventsForDate: _viewModel.getEventsForDate,
        );
    }
  }

  // PHASE 2: 이벤트 탭 처리 (개선된 에러 처리)
  Future<void> _handleEventTap(Map<String, dynamic> event) async {
    final applicationId = event['applicationId'] as String?;

    if (applicationId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공고 정보를 찾을 수 없습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final storageService = StorageService();
      final application = await storageService.getApplicationById(
        applicationId,
      );

      if (application != null) {
        if (!mounted) return;
        _navigateToApplicationDetail(application);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공고 정보를 찾을 수 없습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('공고 정보를 불러오는 중 오류가 발생했습니다: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
