// 통계 화면
// 지원 현황, 합격률, 월별 추이 등을 그래프로 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/application.dart';
import '../../models/application_status.dart';
import '../../services/storage_service.dart';

enum PeriodType { all, thisMonth, last3Months, last6Months, thisYear, custom }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  PeriodType _selectedPeriod = PeriodType.all;

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
    // Phase 2: 실제 데이터에서 월별 통계 계산
    final now = DateTime.now();
    final Map<String, int> monthlyData = {};
    
    // 최근 6개월 데이터 수집
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = '${monthDate.month}월';
      
      final monthApps = _filteredApplications.where((app) {
        return app.createdAt.year == monthDate.year &&
            app.createdAt.month == monthDate.month;
      }).length;
      
      monthlyData[monthKey] = monthApps;
    }

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
            Text(
              AppStrings.monthlyTrend,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: monthlyData.entries.map((entry) {
                  final height = maxValue > 0
                      ? (entry.value / maxValue) * maxBarHeight
                      : 0.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: height > 0 ? height : 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        child: height > 20
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
              ),
            ),
          ],
        ),
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
