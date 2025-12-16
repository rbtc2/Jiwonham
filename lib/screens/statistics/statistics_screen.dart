// 통계 화면
// 지원 현황, 합격률, 월별 추이 등을 그래프로 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';

enum PeriodType { all, thisMonth, last3Months, last6Months, thisYear, custom }

// Phase 1: 월별 추이 표시 기간 타입
enum MonthlyDisplayPeriod {
  last3Months,
  last6Months,
  last12Months,
  thisYear,
  all,
}

// Phase 2: 월별 추이 데이터 기준 타입
enum MonthlyDataCriteria { createdAt, deadline }

// Phase 3: 차트 타입
enum ChartType { bar, line, area }

// Phase 4: 상태별 추이 표시 모드
enum StatusDisplayMode { all, byStatus }

// Phase 4: 누적/비교 모드
enum ChartMode { comparison, cumulative }

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
  int? _cachedTotalApplications;
  int? _cachedNotApplied;
  int? _cachedInProgress;
  int? _cachedPassed;
  int? _cachedRejected;
  String? _cachedFilterKey; // 필터 변경 감지용 키

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
    final now = DateTime.now();
    List<Application> filtered = List.from(_allApplications);

    switch (_selectedPeriod) {
      case PeriodType.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        filtered = filtered
            .where(
              (app) =>
                  app.createdAt.isAfter(startOfMonth) ||
                  app.createdAt.isAtSameMomentAs(startOfMonth),
            )
            .toList();
        break;
      case PeriodType.last3Months:
        final threeMonthsAgo = now.subtract(const Duration(days: 90));
        filtered = filtered
            .where(
              (app) =>
                  app.createdAt.isAfter(threeMonthsAgo) ||
                  app.createdAt.isAtSameMomentAs(threeMonthsAgo),
            )
            .toList();
        break;
      case PeriodType.last6Months:
        final sixMonthsAgo = now.subtract(const Duration(days: 180));
        filtered = filtered
            .where(
              (app) =>
                  app.createdAt.isAfter(sixMonthsAgo) ||
                  app.createdAt.isAtSameMomentAs(sixMonthsAgo),
            )
            .toList();
        break;
      case PeriodType.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        filtered = filtered
            .where(
              (app) =>
                  app.createdAt.isAfter(startOfYear) ||
                  app.createdAt.isAtSameMomentAs(startOfYear),
            )
            .toList();
        break;
      case PeriodType.custom:
        if (_customStartDate != null && _customEndDate != null) {
          // 종료일의 끝 시간까지 포함하기 위해 23:59:59로 설정
          final endDate = DateTime(
            _customEndDate!.year,
            _customEndDate!.month,
            _customEndDate!.day,
            23,
            59,
            59,
          );
          filtered = filtered
              .where(
                (app) =>
                    (app.createdAt.isAfter(_customStartDate!) ||
                        app.createdAt.isAtSameMomentAs(_customStartDate!)) &&
                    (app.createdAt.isBefore(endDate) ||
                        app.createdAt.isAtSameMomentAs(endDate)),
              )
              .toList();
        }
        break;
      case PeriodType.all:
        // 전체 기간 - 필터링 없음
        break;
    }

    setState(() {
      _filteredApplications = filtered;
    });

    // Phase 1: 기간 필터 변경 시 월별 표시 기간 자동 조정
    _adjustMonthlyDisplayPeriod();
  }

  // Phase 1: 기간 필터에 따라 월별 표시 기간 자동 조정
  void _adjustMonthlyDisplayPeriod() {
    MonthlyDisplayPeriod? suggestedPeriod;

    switch (_selectedPeriod) {
      case PeriodType.thisMonth:
        suggestedPeriod = MonthlyDisplayPeriod.last3Months;
        break;
      case PeriodType.last3Months:
        suggestedPeriod = MonthlyDisplayPeriod.last3Months;
        break;
      case PeriodType.last6Months:
        suggestedPeriod = MonthlyDisplayPeriod.last6Months;
        break;
      case PeriodType.thisYear:
        suggestedPeriod = MonthlyDisplayPeriod.thisYear;
        break;
      case PeriodType.all:
        suggestedPeriod = MonthlyDisplayPeriod.all;
        break;
      case PeriodType.custom:
        // 사용자 지정 기간은 현재 설정 유지
        break;
    }

    if (suggestedPeriod != null && _monthlyDisplayPeriod != suggestedPeriod) {
      setState(() {
        _monthlyDisplayPeriod = suggestedPeriod!;
      });
    }
  }

  // Phase 7: 필터 키 생성 (캐시 무효화 감지용)
  String _getFilterKey() {
    return '${_selectedPeriod}_${_customStartDate?.millisecondsSinceEpoch}_${_customEndDate?.millisecondsSinceEpoch}_${_filteredApplications.length}';
  }

  // Phase 7: 통계 계산 결과 캐싱 및 갱신
  void _updateCachedStatistics() {
    final currentFilterKey = _getFilterKey();
    if (_cachedFilterKey == currentFilterKey &&
        _cachedTotalApplications != null) {
      return; // 캐시가 유효하면 재계산하지 않음
    }

    _cachedTotalApplications = _filteredApplications.length;
    _cachedNotApplied = _filteredApplications
        .where((app) => app.status == ApplicationStatus.notApplied)
        .length;
    _cachedInProgress = _filteredApplications
        .where((app) => app.status == ApplicationStatus.inProgress)
        .length;
    _cachedPassed = _filteredApplications
        .where((app) => app.status == ApplicationStatus.passed)
        .length;
    _cachedRejected = _filteredApplications
        .where((app) => app.status == ApplicationStatus.rejected)
        .length;
    _cachedFilterKey = currentFilterKey;
  }

  // Phase 2, 7: 상태별 통계 계산 (캐싱된 값 사용)
  int get _totalApplications {
    _updateCachedStatistics();
    return _cachedTotalApplications ?? 0;
  }

  int get _notApplied {
    _updateCachedStatistics();
    return _cachedNotApplied ?? 0;
  }

  int get _inProgress {
    _updateCachedStatistics();
    return _cachedInProgress ?? 0;
  }

  int get _passed {
    _updateCachedStatistics();
    return _cachedPassed ?? 0;
  }

  int get _rejected {
    _updateCachedStatistics();
    return _cachedRejected ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statisticsTitle),
        actions: [
          TextButton(
            onPressed: () {
              _showPeriodSelectionDialog(context);
            },
            child: const Text(AppStrings.periodSelection),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 현황
            _buildOverallStatistics(context),
            const SizedBox(height: 24),

            // 월별 지원 추이
            _buildMonthlyTrend(context),
            const SizedBox(height: 24),

            // 합격률
            _buildPassRate(context),
            const SizedBox(height: 24),

            // 주요 통계
            _buildKeyStatistics(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatistics(BuildContext context) {
    // Phase 4: 로딩 상태 처리
    if (_isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.overallStatus,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Phase 2: 실제 데이터 사용
    final total = _totalApplications;
    final data = [
      {
        'label': AppStrings.notApplied,
        'value': _notApplied,
        'color': AppColors.textSecondary,
      },
      {
        'label': AppStrings.inProgress,
        'value': _inProgress,
        'color': AppColors.warning,
      },
      {
        'label': AppStrings.passed,
        'value': _passed,
        'color': AppColors.success,
      },
      {
        'label': AppStrings.rejected,
        'value': _rejected,
        'color': AppColors.error,
      },
    ];

    // Phase 4: 빈 상태 처리
    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.overallStatus,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '데이터가 없습니다',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.overallStatus,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // 원형 차트 (간단한 시각화)
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(painter: PieChartPainter(data)),
                ),
                const SizedBox(width: 16),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              '${item['value']}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '전체 지원: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$total건',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
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
                    // Phase 4: 상태별 모드 선택 버튼
                    IconButton(
                      icon: Icon(
                        _statusDisplayMode == StatusDisplayMode.byStatus
                            ? Icons.layers
                            : Icons.layers_outlined,
                        color: _statusDisplayMode == StatusDisplayMode.byStatus
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      tooltip: _statusDisplayMode == StatusDisplayMode.byStatus
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
                    const SizedBox(width: 4),
                    // Phase 3: 차트 타입 선택 버튼
                    PopupMenuButton<ChartType>(
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
                    const SizedBox(width: 8),
                    // Phase 2: 데이터 기준 선택 버튼
                    PopupMenuButton<MonthlyDataCriteria>(
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
                    const SizedBox(width: 8),
                    // Phase 1: 표시 기간 선택 드롭다운
                    PopupMenuButton<MonthlyDisplayPeriod>(
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
                              _getMonthlyDisplayPeriodText(
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
                      // Phase 4: 누적/비교 모드 선택
                      Expanded(
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
                      return FilterChip(
                        label: Text(_getStatusText(status)),
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
                        selectedColor: _getStatusColor(
                          status,
                        ).withValues(alpha: 0.2),
                        checkmarkColor: _getStatusColor(status),
                        avatar: CircleAvatar(
                          backgroundColor: _getStatusColor(status),
                          radius: 8,
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
            // Phase 3, 4: 차트 타입 및 상태별 모드에 따라 다른 차트 표시
            SizedBox(
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
          ],
        ),
      ),
    );
  }

  // Phase 1: 월별 표시 기간 텍스트 변환
  String _getMonthlyDisplayPeriodText(MonthlyDisplayPeriod period) {
    switch (period) {
      case MonthlyDisplayPeriod.last3Months:
        return AppStrings.last3Months;
      case MonthlyDisplayPeriod.last6Months:
        return AppStrings.last6Months;
      case MonthlyDisplayPeriod.last12Months:
        return '지난 12개월';
      case MonthlyDisplayPeriod.thisYear:
        return AppStrings.thisYear;
      case MonthlyDisplayPeriod.all:
        return AppStrings.allPeriod;
    }
  }

  // Phase 4: 상태 텍스트 변환
  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppStrings.notApplied;
      case ApplicationStatus.applied:
        return '지원완료';
      case ApplicationStatus.inProgress:
        return AppStrings.inProgress;
      case ApplicationStatus.passed:
        return AppStrings.passed;
      case ApplicationStatus.rejected:
        return AppStrings.rejected;
    }
  }

  // Phase 4: 상태 색상 가져오기
  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.notApplied:
        return AppColors.textSecondary;
      case ApplicationStatus.applied:
        return AppColors.info;
      case ApplicationStatus.inProgress:
        return AppColors.warning;
      case ApplicationStatus.passed:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
    }
  }

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
                return Tooltip(
                  message: '${entry.key}: ${entry.value}건',
                  child: GestureDetector(
                    onTap: () {
                      // Phase 5: 상세 정보 다이얼로그 표시
                      _showMonthlyDetailDialog(context, entry.key, entry.value);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 40,
                        height: animatedHeight,
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
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              entry.key,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
                  _showMonthlyDetailDialog(context, entry.key, entry.value);
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
                _showMonthlyDetailDialog(context, monthKey, value);
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
                  _showMonthlyDetailDialog(context, entry.key, entry.value);
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
                _showMonthlyDetailDialog(context, monthKey, value);
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
                          _showStatusMonthlyDetailDialog(
                            context,
                            monthKey,
                            status,
                            value.toInt(),
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
                                  color: _getStatusColor(status),
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
                          _showStatusMonthlyDetailDialog(
                            context,
                            monthKey,
                            status,
                            value.toInt(),
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
                                  color: _getStatusColor(status),
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
              color: _getStatusColor(status),
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
              getStatusColor: _getStatusColor,
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
                color: _getStatusColor(status),
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

    return Container(
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusText(status),
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
            );
          }),
        ],
      ),
    );
  }

  // Phase 5: 월별 상세 정보 다이얼로그 표시
  void _showMonthlyDetailDialog(
    BuildContext context,
    String monthKey,
    int totalCount,
  ) {
    // Phase 5: 해당 월의 상태별 데이터 가져오기
    final statusData = _monthlyDataByStatus?[monthKey];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(monthKey),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phase 5: 전체 건수
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '전체 지원:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '$totalCount건',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Phase 5: 상태별 상세 정보
              if (statusData != null && statusData.isNotEmpty) ...[
                const Divider(),
                ...statusData.entries.map((entry) {
                  final status = entry.key;
                  final count = entry.value;
                  if (count == 0) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusText(status),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Text(
                          '$count건',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // Phase 5: 상태별 월별 상세 정보 다이얼로그 표시
  void _showStatusMonthlyDetailDialog(
    BuildContext context,
    String monthKey,
    ApplicationStatus status,
    int count,
  ) {
    // Phase 5: 해당 월의 전체 상태별 데이터 가져오기
    final statusData = _monthlyDataByStatus?[monthKey];
    final totalCount =
        statusData?.values.fold(0, (sum, count) => sum + count) ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$monthKey - ${_getStatusText(status)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phase 5: 선택한 상태의 건수
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(status),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Text(
                      '$count건',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
              ),
              // Phase 5: 전체 건수 및 비율
              if (totalCount > 0) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '전체 대비:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${((count / totalCount) * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassRate(BuildContext context) {
    // Phase 2: 실제 데이터 사용
    final overallRate = _totalApplications > 0
        ? ((_passed / _totalApplications) * 100).toStringAsFixed(1)
        : '0.0';

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
    final thisMonthRate = thisMonthTotal > 0
        ? ((thisMonthPassed / thisMonthTotal) * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.passRate,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPassRateItem(
                  context,
                  AppStrings.overall,
                  '$overallRate%',
                  '$_passed/$_totalApplications',
                ),
                _buildPassRateItem(
                  context,
                  AppStrings.thisMonth,
                  '$thisMonthRate%',
                  '$thisMonthPassed/$thisMonthTotal',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 합격률 추이 그래프 (간단한 선 그래프)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: LineChartPainter([16.7, 20.0, 18.5, 19.2]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassRateItem(
    BuildContext context,
    String label,
    String rate,
    String count,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          rate,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          count,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildKeyStatistics(BuildContext context) {
    // Phase 6: 실제 데이터 계산
    // 평균 지원 기간 계산 (생성일부터 현재까지의 평균 일수)
    final now = DateTime.now();
    final applicationsWithPeriod = _filteredApplications
        .where((app) => app.createdAt.isBefore(now))
        .toList();
    final averagePeriod = applicationsWithPeriod.isEmpty
        ? 0
        : (applicationsWithPeriod
                      .map((app) => now.difference(app.createdAt).inDays)
                      .fold(0, (sum, days) => sum + days) /
                  applicationsWithPeriod.length)
              .round();

    // 가장 많이 지원한 직무 계산
    final positionCounts = <String, int>{};
    for (final app in _filteredApplications) {
      if (app.position != null && app.position!.isNotEmpty) {
        final position = app.position!;
        positionCounts[position] = (positionCounts[position] ?? 0) + 1;
      }
    }
    final mostAppliedPosition = positionCounts.isEmpty
        ? '없음'
        : positionCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
    final mostAppliedPositionCount = positionCounts.isEmpty
        ? 0
        : positionCounts[mostAppliedPosition] ?? 0;

    // 진행 중인 공고 수 (이미 계산된 _inProgress 사용)
    final inProgressCount = _inProgress;

    // 마감 임박 공고 수 (D-7 이내)
    final urgentCount = _filteredApplications
        .where((app) => app.isUrgent)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.keyStatistics,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              context,
              AppStrings.averageApplicationPeriod,
              averagePeriod > 0 ? '$averagePeriod일' : '데이터 없음',
            ),
            const Divider(),
            _buildStatItem(
              context,
              AppStrings.mostAppliedPosition,
              mostAppliedPositionCount > 0
                  ? '$mostAppliedPosition ($mostAppliedPositionCount건)'
                  : '데이터 없음',
            ),
            const Divider(),
            _buildStatItem(
              context,
              AppStrings.inProgressApplications,
              '$inProgressCount건',
            ),
            const Divider(),
            _buildStatItem(
              context,
              AppStrings.urgentApplicationsCount,
              '$urgentCount건',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
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

// 원형 차트 페인터
class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  PieChartPainter(this.data)
    : total = data.fold(
        0.0,
        (sum, item) => sum + (item['value'] as int).toDouble(),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * (3.14159 / 180); // -90도부터 시작

    for (var item in data) {
      final value = (item['value'] as int).toDouble();
      final sweepAngle = (value / total) * 2 * 3.14159;
      final color = item['color'] as Color;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // 중앙 원 (도넛 차트 효과)
    final centerPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! PieChartPainter) return true;
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}

// 선 그래프 페인터
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;

  LineChartPainter(this.data)
    : maxValue = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final stepY = size.height / maxValue;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] * stepY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // 점 그리기
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! LineChartPainter) return true;
    return oldDelegate.data != data || oldDelegate.maxValue != maxValue;
  }
}

// Phase 3: 그리드 라인 페인터
class GridLinePainter extends CustomPainter {
  final double maxValue;
  final double maxHeight;
  final int entryCount;

  GridLinePainter({
    required this.maxValue,
    required this.maxHeight,
    required this.entryCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (maxValue == 0) return;

    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Phase 3: Y축 눈금 (최대 5개)
    final gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      final y = (maxHeight / gridLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! GridLinePainter) return true;
    return oldDelegate.maxValue != maxValue ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.entryCount != entryCount;
  }
}

// Phase 3: 월별 선 그래프 페인터
class MonthlyLineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double maxHeight;
  final int entryCount;

  MonthlyLineChartPainter({
    required this.data,
    required this.maxValue,
    required this.maxHeight,
    required this.entryCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue == 0) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final stepY = maxHeight / maxValue;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (data[i] * stepY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Phase 3: 점 그리기
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! MonthlyLineChartPainter) return true;
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.entryCount != entryCount;
  }
}

// Phase 3: 영역 차트 페인터
class AreaChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double maxHeight;
  final int entryCount;

  AreaChartPainter({
    required this.data,
    required this.maxValue,
    required this.maxHeight,
    required this.entryCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue == 0) return;

    final areaPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final stepY = maxHeight / maxValue;

    // Phase 3: 영역 경로 생성
    path.moveTo(0, maxHeight);
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (data[i] * stepY);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, maxHeight);
    path.close();

    // Phase 3: 영역 그리기
    canvas.drawPath(path, areaPaint);

    // Phase 3: 선 그리기
    final linePath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (data[i] * stepY);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }

      // Phase 3: 점 그리기
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! AreaChartPainter) return true;
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.entryCount != entryCount;
  }
}

// Phase 4: 상태별 선 그래프 페인터
class StatusLineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double maxHeight;
  final int entryCount;
  final Color color;

  StatusLineChartPainter({
    required this.data,
    required this.maxValue,
    required this.maxHeight,
    required this.entryCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final stepY = maxHeight / maxValue;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (data[i] * stepY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Phase 4: 점 그리기
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! StatusLineChartPainter) return true;
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.entryCount != entryCount ||
        oldDelegate.color != color;
  }
}

// Phase 4: 상태별 영역 차트 페인터
class StatusAreaChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double maxHeight;
  final int entryCount;
  final Color color;

  StatusAreaChartPainter({
    required this.data,
    required this.maxValue,
    required this.maxHeight,
    required this.entryCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue == 0) return;

    final areaPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final stepY = maxHeight / maxValue;

    // Phase 4: 영역 경로 생성
    path.moveTo(0, maxHeight);
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (data[i] * stepY);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, maxHeight);
    path.close();

    // Phase 4: 영역 그리기
    canvas.drawPath(path, areaPaint);

    // Phase 4: 선 그리기
    final linePath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (data[i] * stepY);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }

      // Phase 4: 점 그리기
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! StatusAreaChartPainter) return true;
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.entryCount != entryCount ||
        oldDelegate.color != color;
  }
}

// Phase 4: 스택 영역 차트 페인터 (누적 모드)
class StackedAreaChartPainter extends CustomPainter {
  final Map<ApplicationStatus, List<double>> statusData;
  final double maxValue;
  final double maxHeight;
  final int entryCount;
  final Color Function(ApplicationStatus) getStatusColor;

  StackedAreaChartPainter({
    required this.statusData,
    required this.maxValue,
    required this.maxHeight,
    required this.entryCount,
    required this.getStatusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (statusData.isEmpty || maxValue == 0) return;

    final stepX = size.width / (entryCount - 1);
    final stepY = maxHeight / maxValue;

    // Phase 4: 누적 데이터 계산
    final cumulativeData = <ApplicationStatus, List<double>>{};

    for (final statusEntry in statusData.entries) {
      final status = statusEntry.key;
      final data = statusEntry.value;
      double cumulativeSum = 0;
      cumulativeData[status] = data.map((value) {
        cumulativeSum += value;
        return cumulativeSum;
      }).toList();
    }

    // Phase 4: 아래에서부터 스택 영역 그리기
    double previousY = maxHeight;
    for (final statusEntry in statusData.entries.toList().reversed) {
      final status = statusEntry.key;
      final data = statusEntry.value;
      final cumulative = cumulativeData[status]!;

      final areaPaint = Paint()
        ..color = getStatusColor(status).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      final linePaint = Paint()
        ..color = getStatusColor(status)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(0, previousY);

      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final y = maxHeight - (cumulative[i] * stepY);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, previousY);
      path.close();

      canvas.drawPath(path, areaPaint);

      // Phase 4: 상단 선 그리기
      final linePath = Path();
      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final y = maxHeight - (cumulative[i] * stepY);

        if (i == 0) {
          linePath.moveTo(x, y);
        } else {
          linePath.lineTo(x, y);
        }
      }
      canvas.drawPath(linePath, linePaint);

      previousY = maxHeight - (cumulative.last * stepY);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Phase 7: 성능 최적화 - 데이터가 변경된 경우에만 재그리기
    if (oldDelegate is! StackedAreaChartPainter) return true;
    // Map 비교는 복잡하므로 간단히 entryCount와 maxValue만 비교
    return oldDelegate.maxValue != maxValue ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.entryCount != entryCount ||
        oldDelegate.statusData.length != statusData.length;
  }
}
