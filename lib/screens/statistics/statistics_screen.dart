// 통계 화면
// 지원 현황, 합격률, 월별 추이 등을 그래프로 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';
// Phase 9-1: 타입 및 Enum 분리
import 'models/period_type.dart';
import 'models/monthly_display_period.dart';
import 'models/monthly_data_criteria.dart';
import 'models/chart_type.dart';
import 'models/status_display_mode.dart';
import 'models/chart_mode.dart';
// Phase 9-2: CustomPainter 클래스 분리
import 'painters/grid_line_painter.dart';
import 'painters/monthly_line_chart_painter.dart';
import 'painters/area_chart_painter.dart';
import 'painters/status_line_chart_painter.dart';
import 'painters/status_area_chart_painter.dart';
import 'painters/stacked_area_chart_painter.dart';
// Phase 9-3: 위젯 분리
import 'widgets/overall_statistics_card.dart';
import 'widgets/pass_rate_card.dart';
import 'widgets/key_statistics_card.dart';
// Phase 9-4: 헬퍼 함수 분리
import 'utils/statistics_helpers.dart';
// Phase 9-5: 다이얼로그 분리
import 'widgets/monthly_detail_dialog.dart';
import 'widgets/status_monthly_detail_dialog.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  PeriodType _selectedPeriod = PeriodType.all;

  // 사용자 지정 기간 선택
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Phase 1: 월별 추이 표시 기간 선택
  MonthlyDisplayPeriod _monthlyDisplayPeriod = MonthlyDisplayPeriod.last6Months;

  // Phase 2: 월별 추이 데이터 기준 선택
  MonthlyDataCriteria _monthlyDataCriteria = MonthlyDataCriteria.createdAt;

  // Phase 3: 차트 타입 선택
  ChartType _chartType = ChartType.bar;

  // Phase 4: 상태별 추이 표시 모드
  StatusDisplayMode _statusDisplayMode = StatusDisplayMode.all;

  // Phase 4: 선택된 상태 필터 (null이면 전체)
  Set<ApplicationStatus> _selectedStatuses = {};

  // Phase 4: 누적/비교 모드
  ChartMode _chartMode = ChartMode.comparison;

  // Phase 2: 상태별 월별 데이터 (Phase 4에서 사용)
  Map<String, Map<ApplicationStatus, int>>? _monthlyDataByStatus;

  // Phase 1: 실제 데이터 관리
  List<Application> _allApplications = [];
  List<Application> _filteredApplications = [];
  bool _isLoading = true;

  // Phase 7: 성능 최적화 - 통계 계산 결과 캐싱
  final StatisticsCache _statisticsCache = StatisticsCache();

  @override
  void initState() {
    super.initState();
    // Phase 5: 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    // Phase 1: 데이터 로드
    _loadApplications();
  }

  @override
  void dispose() {
    // Phase 5: 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Phase 5: 앱이 포그라운드로 돌아올 때 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 데이터 새로고침
      _loadApplications();
    }
  }

  // Phase 1: 데이터 로드 메서드
  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();
      final applications = await storageService.getAllApplications();

      if (!mounted) return;

      setState(() {
        _allApplications = applications;
        _isLoading = false;
      });

      // Phase 3: 기간 필터링 적용
      _applyPeriodFilter();

      // Phase 1: 기간 필터에 따라 월별 표시 기간 자동 조정
      _adjustMonthlyDisplayPeriod();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Phase 3: 기간 필터링 적용
  void _applyPeriodFilter() {
    final filtered = applyPeriodFilter(
      _allApplications,
      _selectedPeriod,
      _customStartDate,
      _customEndDate,
    );

    setState(() {
      _filteredApplications = filtered;
    });

    // Phase 1: 기간 필터 변경 시 월별 표시 기간 자동 조정
    _adjustMonthlyDisplayPeriod();
  }

  // Phase 1: 기간 필터에 따라 월별 표시 기간 자동 조정
  void _adjustMonthlyDisplayPeriod() {
    final suggestedPeriod = adjustMonthlyDisplayPeriod(_selectedPeriod);

    if (suggestedPeriod != null && _monthlyDisplayPeriod != suggestedPeriod) {
      setState(() {
        _monthlyDisplayPeriod = suggestedPeriod;
      });
    }
  }

  // Phase 7: 통계 계산 결과 캐싱 및 갱신
  void _updateCachedStatistics() {
    final currentFilterKey = getFilterKey(
      _selectedPeriod,
      _customStartDate,
      _customEndDate,
      _filteredApplications.length,
    );
    _statisticsCache.update(_filteredApplications, currentFilterKey);
  }

  // Phase 2, 7: 상태별 통계 계산 (캐싱된 값 사용)
  int get _totalApplications {
    _updateCachedStatistics();
    return _statisticsCache.totalApplications ?? 0;
  }

  int get _notApplied {
    _updateCachedStatistics();
    return _statisticsCache.notApplied ?? 0;
  }

  int get _inProgress {
    _updateCachedStatistics();
    return _statisticsCache.inProgress ?? 0;
  }

  int get _passed {
    _updateCachedStatistics();
    return _statisticsCache.passed ?? 0;
  }

  int get _rejected {
    _updateCachedStatistics();
    return _statisticsCache.rejected ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statisticsTitle),
        actions: [
          // Phase 8: 접근성 개선 - 시맨틱 레이블 추가
          Semantics(
            label: '기간 선택 버튼. 현재 선택된 기간을 변경할 수 있습니다.',
            button: true,
            child: TextButton(
              onPressed: () {
                _showPeriodSelectionDialog(context);
              },
              child: const Text(AppStrings.periodSelection),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 8: 접근성 개선 - 각 섹션에 시맨틱 레이블 추가
            Semantics(
              label: '전체 현황 통계',
              header: true,
              child: OverallStatisticsCard(
                isLoading: _isLoading,
                total: _totalApplications,
                notApplied: _notApplied,
                inProgress: _inProgress,
                passed: _passed,
                rejected: _rejected,
              ),
            ),
            const SizedBox(height: 24),

            Semantics(
              label: '월별 지원 추이 차트',
              header: true,
              child: _buildMonthlyTrend(context),
            ),
            const SizedBox(height: 24),

            Semantics(
              label: '합격률 통계',
              header: true,
              child: _buildPassRate(context),
            ),
            const SizedBox(height: 24),

            Semantics(
              label: '주요 통계 정보',
              header: true,
              child: KeyStatisticsCard(
                filteredApplications: _filteredApplications,
                inProgress: _inProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend(BuildContext context) {
    // Phase 1: 선택한 표시 기간에 따라 월별 데이터 계산
    final now = DateTime.now();
    final Map<String, int> monthlyData = {};

    // Phase 1: 표시할 월 수 결정
    int monthsToShow = 6; // 기본값
    DateTime startDate;

    switch (_monthlyDisplayPeriod) {
      case MonthlyDisplayPeriod.last3Months:
        monthsToShow = 3;
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case MonthlyDisplayPeriod.last6Months:
        monthsToShow = 6;
        startDate = DateTime(now.year, now.month - 5, 1);
        break;
      case MonthlyDisplayPeriod.last12Months:
        monthsToShow = 12;
        startDate = DateTime(now.year, now.month - 11, 1);
        break;
      case MonthlyDisplayPeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
        monthsToShow = now.month;
        break;
      case MonthlyDisplayPeriod.all:
        // 전체 기간: 데이터가 있는 첫 번째 월부터 현재까지
        if (_filteredApplications.isEmpty) {
          monthsToShow = 6;
          startDate = DateTime(now.year, now.month - 5, 1);
        } else {
          final earliestDate = _filteredApplications
              .map((app) => app.createdAt)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          startDate = DateTime(earliestDate.year, earliestDate.month, 1);
          final monthsDiff =
              (now.year - startDate.year) * 12 +
              (now.month - startDate.month) +
              1;
          monthsToShow = monthsDiff > 24 ? 24 : monthsDiff; // 최대 24개월로 제한
        }
        break;
    }

    // Phase 2: 선택한 기준에 따라 날짜 가져오기 헬퍼 함수
    DateTime getDateForCriteria(Application app) {
      switch (_monthlyDataCriteria) {
        case MonthlyDataCriteria.createdAt:
          return app.createdAt;
        case MonthlyDataCriteria.deadline:
          return app.deadline;
      }
    }

    // Phase 2: 상태별 월별 데이터 계산 (캐싱 및 향후 확장용)
    final Map<String, Map<ApplicationStatus, int>> monthlyDataByStatus = {};

    // Phase 1, 2: 선택한 기간과 기준에 맞게 월별 데이터 수집
    if (_monthlyDisplayPeriod == MonthlyDisplayPeriod.all) {
      // 전체 기간: 최근 24개월 데이터 표시 (년도 정보 포함)
      final Map<String, int> monthCounts = {};

      // 최근 24개월 범위 계산
      final earliestDate = now.subtract(const Duration(days: 730)); // 약 24개월

      for (final app in _filteredApplications) {
        final dateForCriteria = getDateForCriteria(app);
        if (dateForCriteria.isBefore(earliestDate)) continue;

        // 년도와 월 정보를 포함한 키 생성
        final monthKey =
            '${dateForCriteria.year}-${dateForCriteria.month.toString().padLeft(2, '0')}';
        monthCounts[monthKey] = (monthCounts[monthKey] ?? 0) + 1;

        // Phase 2: 상태별 데이터도 함께 계산
        if (!monthlyDataByStatus.containsKey(monthKey)) {
          monthlyDataByStatus[monthKey] = {};
        }
        monthlyDataByStatus[monthKey]![app.status] =
            (monthlyDataByStatus[monthKey]![app.status] ?? 0) + 1;
      }

      // 날짜 순서대로 정렬
      final sortedEntries = monthCounts.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      // 최대 24개월까지만 표시 (최신순)
      final entriesToDisplay = sortedEntries.length > 24
          ? sortedEntries.sublist(sortedEntries.length - 24)
          : sortedEntries;

      for (final entry in entriesToDisplay) {
        // "2024-01" 형식을 "1월" 형식으로 변환
        final parts = entry.key.split('-');
        final month = int.parse(parts[1]);
        final monthKeyText = '$month월';
        monthlyData[monthKeyText] = entry.value;
      }
    } else {
      // 특정 기간: 선택한 기간에 맞게 월별 데이터 수집
      for (int i = monthsToShow - 1; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthKey = '${monthDate.month}월';

        // Phase 2: 상태별 데이터도 함께 계산
        monthlyDataByStatus[monthKey] = {};

        final monthApps = _filteredApplications.where((app) {
          final dateForCriteria = getDateForCriteria(app);
          final matches =
              dateForCriteria.year == monthDate.year &&
              dateForCriteria.month == monthDate.month;

          // Phase 2: 상태별 카운트
          if (matches) {
            monthlyDataByStatus[monthKey]![app.status] =
                (monthlyDataByStatus[monthKey]![app.status] ?? 0) + 1;
          }

          return matches;
        }).length;

        monthlyData[monthKey] = monthApps;
      }
    }

    // Phase 2: 상태별 데이터 캐싱 (향후 확장용)
    _monthlyDataByStatus = monthlyDataByStatus;

    if (monthlyData.isEmpty || monthlyData.values.every((v) => v == 0)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.monthlyTrend,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    '데이터가 없습니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
    final chartHeight = 200.0;
    // 텍스트와 간격을 위한 공간 확보 (8px 간격 + 약 20px 텍스트)
    final textAreaHeight = 28.0;
    final maxBarHeight = chartHeight - textAreaHeight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 1: 헤더와 표시 기간 선택 UI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.monthlyTrend,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                // Phase 1, 2, 3, 4: 표시 기간, 데이터 기준, 차트 타입, 상태별 모드 선택
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phase 4, 8: 상태별 모드 선택 버튼 (접근성 개선)
                    Semantics(
                      label: _statusDisplayMode == StatusDisplayMode.byStatus
                          ? '전체 보기 모드로 전환'
                          : '상태별 보기 모드로 전환',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          _statusDisplayMode == StatusDisplayMode.byStatus
                              ? Icons.layers
                              : Icons.layers_outlined,
                          color:
                              _statusDisplayMode == StatusDisplayMode.byStatus
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        tooltip:
                            _statusDisplayMode == StatusDisplayMode.byStatus
                            ? '전체 보기'
                            : '상태별 보기',
                        onPressed: () {
                          setState(() {
                            _statusDisplayMode =
                                _statusDisplayMode == StatusDisplayMode.byStatus
                                ? StatusDisplayMode.all
                                : StatusDisplayMode.byStatus;
                            // 상태별 모드로 전환 시 모든 상태 선택
                            if (_statusDisplayMode ==
                                StatusDisplayMode.byStatus) {
                              _selectedStatuses = Set.from(
                                ApplicationStatus.values,
                              );
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Phase 3, 8: 차트 타입 선택 버튼 (접근성 개선)
                    Semantics(
                      label:
                          '차트 타입 선택. 현재: ${_chartType == ChartType.bar
                              ? "바 차트"
                              : _chartType == ChartType.line
                              ? "선 그래프"
                              : "영역 차트"}',
                      button: true,
                      child: PopupMenuButton<ChartType>(
                        initialValue: _chartType,
                        onSelected: (value) {
                          setState(() {
                            _chartType = value;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _chartType == ChartType.bar
                                    ? Icons.bar_chart
                                    : _chartType == ChartType.line
                                    ? Icons.show_chart
                                    : Icons.area_chart,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<ChartType>(
                            value: ChartType.bar,
                            child: const Row(
                              children: [
                                Icon(Icons.bar_chart, size: 20),
                                SizedBox(width: 8),
                                Text('바 차트'),
                              ],
                            ),
                          ),
                          PopupMenuItem<ChartType>(
                            value: ChartType.line,
                            child: const Row(
                              children: [
                                Icon(Icons.show_chart, size: 20),
                                SizedBox(width: 8),
                                Text('선 그래프'),
                              ],
                            ),
                          ),
                          PopupMenuItem<ChartType>(
                            value: ChartType.area,
                            child: const Row(
                              children: [
                                Icon(Icons.area_chart, size: 20),
                                SizedBox(width: 8),
                                Text('영역 차트'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Phase 2, 8: 데이터 기준 선택 버튼 (접근성 개선)
                    Semantics(
                      label:
                          '데이터 기준 선택. 현재: ${_monthlyDataCriteria == MonthlyDataCriteria.createdAt ? "생성일" : "마감일"}',
                      button: true,
                      child: PopupMenuButton<MonthlyDataCriteria>(
                        initialValue: _monthlyDataCriteria,
                        onSelected: (value) {
                          setState(() {
                            _monthlyDataCriteria = value;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _monthlyDataCriteria ==
                                        MonthlyDataCriteria.createdAt
                                    ? Icons.add_circle_outline
                                    : Icons.event_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _monthlyDataCriteria ==
                                        MonthlyDataCriteria.createdAt
                                    ? '생성일'
                                    : '마감일',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<MonthlyDataCriteria>(
                            value: MonthlyDataCriteria.createdAt,
                            child: const Row(
                              children: [
                                Icon(Icons.add_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text('생성일 기준'),
                              ],
                            ),
                          ),
                          PopupMenuItem<MonthlyDataCriteria>(
                            value: MonthlyDataCriteria.deadline,
                            child: const Row(
                              children: [
                                Icon(Icons.event_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('마감일 기준'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Phase 1, 8: 표시 기간 선택 드롭다운 (접근성 개선)
                    Semantics(
                      label:
                          '표시 기간 선택. 현재: ${getMonthlyDisplayPeriodText(_monthlyDisplayPeriod)}',
                      button: true,
                      child: PopupMenuButton<MonthlyDisplayPeriod>(
                        initialValue: _monthlyDisplayPeriod,
                        onSelected: (value) {
                          setState(() {
                            _monthlyDisplayPeriod = value;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getMonthlyDisplayPeriodText(
                                  _monthlyDisplayPeriod,
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<MonthlyDisplayPeriod>(
                            value: MonthlyDisplayPeriod.last3Months,
                            child: Text(AppStrings.last3Months),
                          ),
                          PopupMenuItem<MonthlyDisplayPeriod>(
                            value: MonthlyDisplayPeriod.last6Months,
                            child: Text(AppStrings.last6Months),
                          ),
                          PopupMenuItem<MonthlyDisplayPeriod>(
                            value: MonthlyDisplayPeriod.last12Months,
                            child: const Text('지난 12개월'),
                          ),
                          PopupMenuItem<MonthlyDisplayPeriod>(
                            value: MonthlyDisplayPeriod.thisYear,
                            child: Text(AppStrings.thisYear),
                          ),
                          PopupMenuItem<MonthlyDisplayPeriod>(
                            value: MonthlyDisplayPeriod.all,
                            child: Text(AppStrings.allPeriod),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Phase 4: 상태별 모드 선택 및 범례
            if (_statusDisplayMode == StatusDisplayMode.byStatus &&
                _monthlyDataByStatus != null)
              Column(
                children: [
                  // Phase 4: 상태 필터 및 모드 선택
                  Row(
                    children: [
                      // Phase 4, 8: 누적/비교 모드 선택 (접근성 개선)
                      Expanded(
                        child: Semantics(
                          label:
                              '차트 모드 선택. 현재: ${_chartMode == ChartMode.comparison ? "비교 모드" : "누적 모드"}',
                          child: SegmentedButton<ChartMode>(
                            segments: const [
                              ButtonSegment<ChartMode>(
                                value: ChartMode.comparison,
                                label: Text('비교'),
                              ),
                              ButtonSegment<ChartMode>(
                                value: ChartMode.cumulative,
                                label: Text('누적'),
                              ),
                            ],
                            selected: {_chartMode},
                            onSelectionChanged: (Set<ChartMode> newSelection) {
                              setState(() {
                                _chartMode = newSelection.first;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Phase 4: 상태별 범례
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: ApplicationStatus.values.map((status) {
                      final isSelected =
                          _selectedStatuses.isEmpty ||
                          _selectedStatuses.contains(status);
                      // Phase 8: 접근성 개선 - 상태 필터에 시맨틱 레이블
                      return Semantics(
                        label:
                            '${getStatusText(status)} 상태 필터. ${isSelected ? "선택됨" : "선택 안 됨"}',
                        button: true,
                        child: FilterChip(
                          label: Text(getStatusText(status)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedStatuses.add(status);
                              } else {
                                _selectedStatuses.remove(status);
                              }
                              // 전체 선택 해제 시 전체 표시
                              if (_selectedStatuses.isEmpty) {
                                _selectedStatuses = Set.from(
                                  ApplicationStatus.values,
                                );
                              }
                            });
                          },
                          selectedColor: getStatusColor(
                            status,
                          ).withValues(alpha: 0.2),
                          checkmarkColor: getStatusColor(status),
                          avatar: CircleAvatar(
                            backgroundColor: getStatusColor(status),
                            radius: 8,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Phase 4: 트렌드 분석 표시
                  if (_monthlyDataByStatus != null &&
                      monthlyData.keys.length >= 2)
                    _buildTrendAnalysis(context, monthlyData.keys.toList()),
                ],
              ),
            // Phase 3, 4, 8: 차트 타입 및 상태별 모드에 따라 다른 차트 표시 (접근성 개선)
            Semantics(
              label:
                  '월별 지원 추이 ${_chartType == ChartType.bar
                      ? "바 차트"
                      : _chartType == ChartType.line
                      ? "선 그래프"
                      : "영역 차트"}. ${monthlyData.entries.map((e) => '${e.key}: ${e.value}건').join(', ')}',
              child: SizedBox(
                height: chartHeight,
                child:
                    _statusDisplayMode == StatusDisplayMode.byStatus &&
                        _monthlyDataByStatus != null
                    ? _buildStatusChart(
                        context,
                        monthlyData,
                        maxValue,
                        chartHeight,
                        textAreaHeight,
                        maxBarHeight,
                      )
                    : _buildChart(
                        context,
                        monthlyData,
                        maxValue,
                        chartHeight,
                        textAreaHeight,
                        maxBarHeight,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Phase 1: 월별 표시 기간 텍스트 변환

  // Phase 3: 차트 타입에 따라 차트 빌드
  Widget _buildChart(
    BuildContext context,
    Map<String, int> monthlyData,
    int maxValue,
    double chartHeight,
    double textAreaHeight,
    double maxBarHeight,
  ) {
    switch (_chartType) {
      case ChartType.bar:
        return _buildBarChart(
          context,
          monthlyData,
          maxValue,
          chartHeight,
          textAreaHeight,
          maxBarHeight,
        );
      case ChartType.line:
        return _buildLineChart(
          context,
          monthlyData,
          maxValue,
          chartHeight,
          textAreaHeight,
        );
      case ChartType.area:
        return _buildAreaChart(
          context,
          monthlyData,
          maxValue,
          chartHeight,
          textAreaHeight,
        );
    }
  }

  // Phase 3: 바 차트 빌드
  Widget _buildBarChart(
    BuildContext context,
    Map<String, int> monthlyData,
    int maxValue,
    double chartHeight,
    double textAreaHeight,
    double maxBarHeight,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: monthlyData.entries.map((entry) {
        final height = maxValue > 0
            ? (entry.value / maxValue) * maxBarHeight
            : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Phase 3: 애니메이션 및 툴팁 추가
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              tween: Tween(begin: 0.0, end: height > 0 ? height : 4),
              builder: (context, animatedHeight, child) {
                // Phase 8: 접근성 개선 - 시맨틱 레이블 및 터치 영역 최적화
                return Semantics(
                  label: '${entry.key}월: ${entry.value}건. 탭하여 상세 정보 보기',
                  button: true,
                  child: Tooltip(
                    message: '${entry.key}: ${entry.value}건',
                    child: GestureDetector(
                      onTap: () {
                        // Phase 5: 상세 정보 다이얼로그 표시
                        showMonthlyDetailDialog(
                          context,
                          entry.key,
                          entry.value,
                          _monthlyDataByStatus,
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          // Phase 8: 터치 영역 최적화 (최소 48x48)
                          width: 40,
                          height: animatedHeight > 0 ? animatedHeight : 48,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 48,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: animatedHeight > 20
                              ? Center(
                                  child: Text(
                                    '${entry.value}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Phase 8: 접근성 개선 - 월 레이블에 시맨틱 추가
            Semantics(
              label: '${entry.key}월',
              child: Text(
                entry.key,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Phase 3: 선 그래프 빌드
  Widget _buildLineChart(
    BuildContext context,
    Map<String, int> monthlyData,
    int maxValue,
    double chartHeight,
    double textAreaHeight,
  ) {
    final entries = monthlyData.entries.toList();
    final maxBarHeight = chartHeight - textAreaHeight;

    return Stack(
      children: [
        // Phase 3: 그리드 라인
        CustomPaint(
          size: Size.infinite,
          painter: GridLinePainter(
            maxValue: maxValue.toDouble(),
            maxHeight: maxBarHeight,
            entryCount: entries.length,
          ),
        ),
        // Phase 3: 선 그래프
        CustomPaint(
          size: Size.infinite,
          painter: MonthlyLineChartPainter(
            data: entries.map((e) => e.value.toDouble()).toList(),
            maxValue: maxValue.toDouble(),
            maxHeight: maxBarHeight,
            entryCount: entries.length,
          ),
        ),
        // Phase 3, 5: X축 레이블 및 상호작용
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  // Phase 5: 상세 정보 다이얼로그 표시
                  showMonthlyDetailDialog(
                    context,
                    entry.key,
                    entry.value,
                    _monthlyDataByStatus,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      width:
                          MediaQuery.of(context).size.width / entries.length -
                          16,
                      child: Text(
                        entry.key,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Phase 5: 선 그래프 포인트 클릭 영역
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final monthKey = entry.value.key;
          final value = entry.value.value;
          final stepX =
              MediaQuery.of(context).size.width / (entries.length - 1);
          final x = index * stepX;
          final stepY = maxBarHeight / maxValue;
          final y = maxBarHeight - (value * stepY);

          return Positioned(
            left: x - 15,
            top: y - 15,
            child: GestureDetector(
              onTap: () {
                showMonthlyDetailDialog(
                  context,
                  monthKey,
                  value,
                  _monthlyDataByStatus,
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Phase 3: 영역 차트 빌드
  Widget _buildAreaChart(
    BuildContext context,
    Map<String, int> monthlyData,
    int maxValue,
    double chartHeight,
    double textAreaHeight,
  ) {
    final entries = monthlyData.entries.toList();
    final maxBarHeight = chartHeight - textAreaHeight;

    return Stack(
      children: [
        // Phase 3: 그리드 라인
        CustomPaint(
          size: Size.infinite,
          painter: GridLinePainter(
            maxValue: maxValue.toDouble(),
            maxHeight: maxBarHeight,
            entryCount: entries.length,
          ),
        ),
        // Phase 3: 영역 차트
        CustomPaint(
          size: Size.infinite,
          painter: AreaChartPainter(
            data: entries.map((e) => e.value.toDouble()).toList(),
            maxValue: maxValue.toDouble(),
            maxHeight: maxBarHeight,
            entryCount: entries.length,
          ),
        ),
        // Phase 3, 5: X축 레이블 및 상호작용
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  // Phase 5: 상세 정보 다이얼로그 표시
                  showMonthlyDetailDialog(
                    context,
                    entry.key,
                    entry.value,
                    _monthlyDataByStatus,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      width:
                          MediaQuery.of(context).size.width / entries.length -
                          16,
                      child: Text(
                        entry.key,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Phase 5: 영역 차트 포인트 클릭 영역
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final monthKey = entry.value.key;
          final value = entry.value.value;
          final stepX =
              MediaQuery.of(context).size.width / (entries.length - 1);
          final x = index * stepX;
          final stepY = maxBarHeight / maxValue;
          final y = maxBarHeight - (value * stepY);

          return Positioned(
            left: x - 15,
            top: y - 15,
            child: GestureDetector(
              onTap: () {
                showMonthlyDetailDialog(
                  context,
                  monthKey,
                  value,
                  _monthlyDataByStatus,
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Phase 4: 상태별 차트 빌드
  Widget _buildStatusChart(
    BuildContext context,
    Map<String, int> monthlyData,
    int maxValue,
    double chartHeight,
    double textAreaHeight,
    double maxBarHeight,
  ) {
    if (_monthlyDataByStatus == null || _monthlyDataByStatus!.isEmpty) {
      return Center(
        child: Text(
          '상태별 데이터가 없습니다',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    // Phase 4: 선택된 상태 필터링
    final selectedStatuses = _selectedStatuses.isEmpty
        ? ApplicationStatus.values.toSet()
        : _selectedStatuses;

    // Phase 4: 상태별 데이터 준비
    final entries = monthlyData.keys.toList();
    final statusData = <ApplicationStatus, List<double>>{};

    for (final status in selectedStatuses) {
      statusData[status] = entries.map((monthKey) {
        final statusCount = _monthlyDataByStatus![monthKey]?[status] ?? 0;
        return statusCount.toDouble();
      }).toList();
    }

    // Phase 4: 최대값 계산 (누적 모드인 경우 합계)
    double calculatedMaxValue = maxValue.toDouble();
    if (_chartMode == ChartMode.cumulative) {
      final cumulativeMax = entries
          .map((monthKey) {
            return selectedStatuses
                .map((status) => _monthlyDataByStatus![monthKey]?[status] ?? 0)
                .fold(0, (sum, count) => sum + count);
          })
          .reduce((a, b) => a > b ? a : b);
      calculatedMaxValue = cumulativeMax.toDouble();
    }

    // Phase 4: 차트 타입에 따라 렌더링
    switch (_chartType) {
      case ChartType.bar:
        return _buildStatusBarChart(
          context,
          entries,
          statusData,
          calculatedMaxValue,
          maxBarHeight,
        );
      case ChartType.line:
        return _buildStatusLineChart(
          context,
          entries,
          statusData,
          calculatedMaxValue,
          maxBarHeight,
        );
      case ChartType.area:
        return _buildStatusAreaChart(
          context,
          entries,
          statusData,
          calculatedMaxValue,
          maxBarHeight,
        );
    }
  }

  // Phase 4: 상태별 바 차트 빌드
  Widget _buildStatusBarChart(
    BuildContext context,
    List<String> entries,
    Map<ApplicationStatus, List<double>> statusData,
    double maxValue,
    double maxBarHeight,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final monthKey = entry.value;

        // Phase 4: 누적 모드인 경우 스택 바, 비교 모드인 경우 그룹 바
        if (_chartMode == ChartMode.cumulative) {
          // 누적 바 차트
          double cumulativeHeight = 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 40,
                height: maxBarHeight,
                child: Stack(
                  children: statusData.entries.map((statusEntry) {
                    final status = statusEntry.key;
                    final value = statusEntry.value[index];
                    final height = maxValue > 0
                        ? (value / maxValue) * maxBarHeight
                        : 0.0;
                    final bottom = cumulativeHeight;
                    cumulativeHeight += height;

                    return Positioned(
                      bottom: bottom,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Phase 5: 상태별 상세 정보 다이얼로그 표시
                          showStatusMonthlyDetailDialog(
                            context,
                            monthKey,
                            status,
                            value.toInt(),
                            _monthlyDataByStatus,
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOut,
                            tween: Tween(begin: 0.0, end: height),
                            builder: (context, animatedHeight, child) {
                              return Container(
                                height: animatedHeight,
                                decoration: BoxDecoration(
                                  color: getStatusColor(status),
                                  borderRadius: index == entries.length - 1
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        )
                                      : BorderRadius.zero,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                monthKey,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          );
        } else {
          // 비교 바 차트 (그룹 바)
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 40,
                height: maxBarHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: statusData.entries.map((statusEntry) {
                    final status = statusEntry.key;
                    final value = statusEntry.value[index];
                    final height = maxValue > 0
                        ? (value / maxValue) * maxBarHeight
                        : 0.0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Phase 5: 상태별 상세 정보 다이얼로그 표시
                          showStatusMonthlyDetailDialog(
                            context,
                            monthKey,
                            status,
                            value.toInt(),
                            _monthlyDataByStatus,
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOut,
                            tween: Tween(begin: 0.0, end: height),
                            builder: (context, animatedHeight, child) {
                              return Container(
                                height: animatedHeight,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    topRight: Radius.circular(2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                monthKey,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          );
        }
      }).toList(),
    );
  }

  // Phase 4: 상태별 선 그래프 빌드
  Widget _buildStatusLineChart(
    BuildContext context,
    List<String> entries,
    Map<ApplicationStatus, List<double>> statusData,
    double maxValue,
    double maxBarHeight,
  ) {
    return Stack(
      children: [
        // Phase 3: 그리드 라인
        CustomPaint(
          size: Size.infinite,
          painter: GridLinePainter(
            maxValue: maxValue,
            maxHeight: maxBarHeight,
            entryCount: entries.length,
          ),
        ),
        // Phase 4: 상태별 선 그래프
        ...statusData.entries.map((statusEntry) {
          final status = statusEntry.key;
          final data = statusEntry.value;
          return CustomPaint(
            size: Size.infinite,
            painter: StatusLineChartPainter(
              data: data,
              maxValue: maxValue,
              maxHeight: maxBarHeight,
              entryCount: entries.length,
              color: getStatusColor(status),
            ),
          );
        }),
        // Phase 3: X축 레이블
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: entries.map((entry) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / entries.length - 16,
                child: Text(
                  entry,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Phase 4: 상태별 영역 차트 빌드
  Widget _buildStatusAreaChart(
    BuildContext context,
    List<String> entries,
    Map<ApplicationStatus, List<double>> statusData,
    double maxValue,
    double maxBarHeight,
  ) {
    return Stack(
      children: [
        // Phase 3: 그리드 라인
        CustomPaint(
          size: Size.infinite,
          painter: GridLinePainter(
            maxValue: maxValue,
            maxHeight: maxBarHeight,
            entryCount: entries.length,
          ),
        ),
        // Phase 4: 상태별 영역 차트 (누적 모드인 경우 스택)
        if (_chartMode == ChartMode.cumulative)
          CustomPaint(
            size: Size.infinite,
            painter: StackedAreaChartPainter(
              statusData: statusData,
              maxValue: maxValue,
              maxHeight: maxBarHeight,
              entryCount: entries.length,
              getStatusColor: getStatusColor,
            ),
          )
        else
          ...statusData.entries.map((statusEntry) {
            final status = statusEntry.key;
            final data = statusEntry.value;
            return CustomPaint(
              size: Size.infinite,
              painter: StatusAreaChartPainter(
                data: data,
                maxValue: maxValue,
                maxHeight: maxBarHeight,
                entryCount: entries.length,
                color: getStatusColor(status),
              ),
            );
          }),
        // Phase 3: X축 레이블
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: entries.map((entry) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / entries.length - 16,
                child: Text(
                  entry,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Phase 4: 트렌드 분석 빌드
  Widget _buildTrendAnalysis(BuildContext context, List<String> entries) {
    if (_monthlyDataByStatus == null || entries.length < 2) {
      return const SizedBox.shrink();
    }

    // Phase 4: 각 상태별 트렌드 계산
    final trends = <ApplicationStatus, Map<String, dynamic>>{};

    for (final status in ApplicationStatus.values) {
      if (_selectedStatuses.isNotEmpty && !_selectedStatuses.contains(status)) {
        continue;
      }

      final firstMonth = _monthlyDataByStatus![entries.first]?[status] ?? 0;
      final lastMonth = _monthlyDataByStatus![entries.last]?[status] ?? 0;

      if (firstMonth == 0 && lastMonth == 0) continue;

      final change = lastMonth - firstMonth;
      final percentChange = firstMonth > 0
          ? ((change / firstMonth) * 100).toStringAsFixed(1)
          : change > 0
          ? '100.0'
          : '0.0';

      String trendText;
      IconData trendIcon;
      Color trendColor;

      if (change > 0) {
        trendText = '+$change건 (+$percentChange%)';
        trendIcon = Icons.trending_up;
        trendColor = AppColors.success;
      } else if (change < 0) {
        trendText = '$change건 ($percentChange%)';
        trendIcon = Icons.trending_down;
        trendColor = AppColors.error;
      } else {
        trendText = '변화 없음';
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.textSecondary;
      }

      trends[status] = {
        'text': trendText,
        'icon': trendIcon,
        'color': trendColor,
      };
    }

    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    // Phase 8: 접근성 개선 - 트렌드 분석에 시맨틱 레이블
    return Semantics(
      label:
          '트렌드 분석. ${trends.entries.map((e) => '${getStatusText(e.key)}: ${e.value['text']}').join(', ')}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '트렌드 분석',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...trends.entries.map((entry) {
              final status = entry.key;
              final trend = entry.value;

              // Phase 8: 접근성 개선 - 각 트렌드 항목에 시맨틱 레이블
              return Semantics(
                label: '${getStatusText(status)}: ${trend['text']}',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          getStatusText(status),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Icon(
                        trend['icon'] as IconData,
                        size: 16,
                        color: trend['color'] as Color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend['text'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: trend['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPassRate(BuildContext context) {
    // Phase 3: 이번 달 합격률 계산
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final thisMonthApps = _allApplications
        .where(
          (app) =>
              app.createdAt.isAfter(startOfMonth) ||
              app.createdAt.isAtSameMomentAs(startOfMonth),
        )
        .toList();
    final thisMonthPassed = thisMonthApps
        .where((app) => app.status == ApplicationStatus.passed)
        .length;
    final thisMonthTotal = thisMonthApps.length;

    return PassRateCard(
      total: _totalApplications,
      passed: _passed,
      thisMonthTotal: thisMonthTotal,
      thisMonthPassed: thisMonthPassed,
    );
  }

  void _showPeriodSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.periodSelection),
        content: RadioGroup<PeriodType>(
          groupValue: _selectedPeriod,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              Navigator.pop(context);
              // Phase 3: 기간 필터 적용
              _applyPeriodFilter();
              if (value == PeriodType.custom) {
                _showCustomPeriodDialog(context);
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<PeriodType>(
                title: const Text(AppStrings.allPeriod),
                value: PeriodType.all,
              ),
              RadioListTile<PeriodType>(
                title: const Text(AppStrings.thisMonthPeriod),
                value: PeriodType.thisMonth,
              ),
              RadioListTile<PeriodType>(
                title: const Text(AppStrings.last3Months),
                value: PeriodType.last3Months,
              ),
              RadioListTile<PeriodType>(
                title: const Text(AppStrings.last6Months),
                value: PeriodType.last6Months,
              ),
              RadioListTile<PeriodType>(
                title: const Text(AppStrings.thisYear),
                value: PeriodType.thisYear,
              ),
              RadioListTile<PeriodType>(
                title: const Text(AppStrings.customPeriod),
                value: PeriodType.custom,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  // 사용자 지정 기간 선택 다이얼로그
  Future<void> _showCustomPeriodDialog(BuildContext context) async {
    DateTime? startDate = _customStartDate;
    DateTime? endDate = _customEndDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('사용자 지정 기간 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // 시작일 선택
                ListTile(
                  title: const Text('시작일'),
                  subtitle: Text(
                    startDate != null
                        ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'
                        : '선택 안 함',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: endDate ?? DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                // 종료일 선택
                ListTile(
                  title: const Text('종료일'),
                  subtitle: Text(
                    endDate != null
                        ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                        : '선택 안 함',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        endDate = picked;
                      });
                    }
                  },
                ),
                if (startDate != null && endDate != null)
                  if (startDate!.isAfter(endDate!))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '시작일이 종료일보다 늦을 수 없습니다.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed:
                  startDate != null &&
                      endDate != null &&
                      !startDate!.isAfter(endDate!)
                  ? () {
                      setState(() {
                        _customStartDate = startDate;
                        _customEndDate = endDate;
                      });
                      Navigator.pop(context);
                      _applyPeriodFilter();
                    }
                  : null,
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
