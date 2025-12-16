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
enum MonthlyDisplayPeriod { last3Months, last6Months, last12Months, thisYear, all }

// Phase 2: 월별 추이 데이터 기준 타입
enum MonthlyDataCriteria { createdAt, deadline }

// Phase 3: 차트 타입
enum ChartType { bar, line, area }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  PeriodType _selectedPeriod = PeriodType.all;

  // Phase 1: 월별 추이 표시 기간 선택
  MonthlyDisplayPeriod _monthlyDisplayPeriod = MonthlyDisplayPeriod.last6Months;
  
  // Phase 2: 월별 추이 데이터 기준 선택
  MonthlyDataCriteria _monthlyDataCriteria = MonthlyDataCriteria.createdAt;
  
  // Phase 3: 차트 타입 선택
  ChartType _chartType = ChartType.bar;
  
  // Phase 2: 상태별 월별 데이터 (캐싱용, Phase 4에서 사용 예정)
  // ignore: unused_field
  Map<String, Map<ApplicationStatus, int>>? _monthlyDataByStatus;

  // Phase 1: 실제 데이터 관리
  List<Application> _allApplications = [];
  List<Application> _filteredApplications = [];
  bool _isLoading = true;

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
            .where((app) => app.createdAt.isAfter(startOfMonth) ||
                app.createdAt.isAtSameMomentAs(startOfMonth))
            .toList();
        break;
      case PeriodType.last3Months:
        final threeMonthsAgo = now.subtract(const Duration(days: 90));
        filtered = filtered
            .where((app) => app.createdAt.isAfter(threeMonthsAgo) ||
                app.createdAt.isAtSameMomentAs(threeMonthsAgo))
            .toList();
        break;
      case PeriodType.last6Months:
        final sixMonthsAgo = now.subtract(const Duration(days: 180));
        filtered = filtered
            .where((app) => app.createdAt.isAfter(sixMonthsAgo) ||
                app.createdAt.isAtSameMomentAs(sixMonthsAgo))
            .toList();
        break;
      case PeriodType.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        filtered = filtered
            .where((app) => app.createdAt.isAfter(startOfYear) ||
                app.createdAt.isAtSameMomentAs(startOfYear))
            .toList();
        break;
      case PeriodType.custom:
        // TODO: 사용자 지정 기간 선택 구현
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

  // Phase 2: 상태별 통계 계산
  int get _totalApplications => _filteredApplications.length;
  int get _notApplied => _filteredApplications
      .where((app) => app.status == ApplicationStatus.notApplied)
      .length;
  int get _inProgress => _filteredApplications
      .where((app) => app.status == ApplicationStatus.inProgress)
      .length;
  int get _passed => _filteredApplications
      .where((app) => app.status == ApplicationStatus.passed)
      .length;
  int get _rejected => _filteredApplications
      .where((app) => app.status == ApplicationStatus.rejected)
      .length;

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
          final monthsDiff = (now.year - startDate.year) * 12 + 
                            (now.month - startDate.month) + 1;
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
        final monthKey = '${dateForCriteria.year}-${dateForCriteria.month.toString().padLeft(2, '0')}';
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
          final matches = dateForCriteria.year == monthDate.year &&
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
                // Phase 1, 2, 3: 표시 기간, 데이터 기준, 차트 타입 선택
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                              _monthlyDataCriteria == MonthlyDataCriteria.createdAt
                                  ? Icons.add_circle_outline
                                  : Icons.event_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _monthlyDataCriteria == MonthlyDataCriteria.createdAt
                                  ? '생성일'
                                  : '마감일',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
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
                          _getMonthlyDisplayPeriodText(_monthlyDisplayPeriod),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
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
            // Phase 3: 차트 타입에 따라 다른 차트 표시
            SizedBox(
              height: chartHeight,
              child: _buildChart(
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
                      // Phase 3: 상세 정보 표시 (선택사항)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${entry.key}: ${entry.value}건'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
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
                );
              },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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
                  entry.key,
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
                  entry.key,
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

  Widget _buildPassRate(BuildContext context) {
    // Phase 2: 실제 데이터 사용
    final overallRate = _totalApplications > 0
        ? ((_passed / _totalApplications) * 100).toStringAsFixed(1)
        : '0.0';
    
    // Phase 3: 이번 달 합격률 계산
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final thisMonthApps = _allApplications
        .where((app) => app.createdAt.isAfter(startOfMonth) ||
            app.createdAt.isAtSameMomentAs(startOfMonth))
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
            _buildStatItem(context, AppStrings.averageApplicationPeriod, '15일'),
            const Divider(),
            _buildStatItem(context, AppStrings.mostAppliedPosition, '개발자 (5건)'),
            const Divider(),
            _buildStatItem(context, AppStrings.inProgressApplications, '5건'),
            const Divider(),
            _buildStatItem(context, AppStrings.urgentApplicationsCount, '3건'),
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
                // TODO: 사용자 지정 기간 선택
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 선 그래프 페인터
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;

  LineChartPainter(this.data) : maxValue = data.reduce((a, b) => a > b ? a : b);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
