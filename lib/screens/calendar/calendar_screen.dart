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
import 'widgets/month_year_picker.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/dialogs/modern_bottom_sheet.dart';

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showMonthYearPicker(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMonthYearText(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: IconButton(
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
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime.now();
                  _selectedDate = DateTime.now();
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                AppStrings.today,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _viewModel.isLoading
          ? _buildLoadingState(context)
          : !_viewModel.hasEvents
          ? _buildEmptyCalendarState(context)
          : Column(
              children: [
                // 캘린더 - 필요한 만큼만 공간 차지
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildCalendar(context),
                ),
                // 범례
                const CalendarLegend(),
                // 선택된 날짜의 일정 목록 - 남은 공간을 차지
                Flexible(
                  child: CalendarScheduleList(
                    selectedDate: _selectedDate,
                    events: _viewModel.getEventsForDate(_selectedDate),
                    getEventTitle: _viewModel.getEventTitle,
                    onEventTap: (event) => _handleEventTap(event),
                  ),
                ),
              ],
            ),
    );
  }

  // PHASE 4: 로딩 상태 UI
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ModernCard(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '일정을 불러오는 중...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '잠시만 기다려주세요',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PHASE 4: 빈 캘린더 상태 UI (이벤트가 없을 때)
  Widget _buildEmptyCalendarState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ModernCard(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '등록된 일정이 없습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '공고를 추가하면 캘린더에 표시됩니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthYearText() {
    return '${_currentMonth.year}년 ${_currentMonth.month}월';
  }

  // 년/월 선택 다이얼로그 표시
  Future<void> _showMonthYearPicker(BuildContext context) async {
    final pickerKey = GlobalKey<State<MonthYearPicker>>();
    
    await ModernBottomSheet.showCustom(
      context: context,
      header: ModernBottomSheetHeader(
        title: '날짜 선택',
        icon: Icons.calendar_today_outlined,
        iconColor: AppColors.primary,
      ),
      content: MonthYearPicker(
        key: pickerKey,
        initialYear: _currentMonth.year,
        initialMonth: _currentMonth.month,
        onSelected: (year, month) {
          // 이 콜백은 실시간 업데이트용 (필요시 사용)
        },
      ),
      actions: ModernBottomSheetActions(
        cancelText: '취소',
        confirmText: '확인',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          final state = pickerKey.currentState;
          if (state != null && state is MonthYearPickerState) {
            final year = state.selectedYear;
            final month = state.selectedMonth;
            setState(() {
              _currentMonth = DateTime(year, month);
            });
            Navigator.pop(context);
          }
        },
      ),
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    );
  }

  Widget _buildCalendar(BuildContext context) {
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
