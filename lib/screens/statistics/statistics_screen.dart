// 통계 화면
// 지원 현황, 합격률, 월별 추이 등을 그래프로 보여주는 화면

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

enum PeriodType { all, thisMonth, last3Months, last6Months, thisYear, custom }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  PeriodType _selectedPeriod = PeriodType.all;

  // 더미 데이터
  final int _totalApplications = 12;
  final int _inProgress = 5;
  final int _passed = 2;
  final int _rejected = 3;
  final int _notApplied = 2;

  final Map<String, int> _monthlyData = {'1월': 4, '2월': 5, '3월': 3};

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
            const SizedBox(height: 24),

            // 일정 현황
            _buildScheduleStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatistics(BuildContext context) {
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
    final maxValue = _monthlyData.values.reduce((a, b) => a > b ? a : b);
    final chartHeight = 200.0;

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
                children: _monthlyData.entries.map((entry) {
                  final height = (entry.value / maxValue) * chartHeight;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
    final overallRate = totalApplications > 0
        ? ((_passed / totalApplications) * 100).toStringAsFixed(1)
        : '0.0';
    final thisMonthRate = '20.0'; // 더미 데이터

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
                  '$_passed/$totalApplications',
                ),
                _buildPassRateItem(
                  context,
                  AppStrings.thisMonth,
                  '$thisMonthRate%',
                  '1/5',
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

  Widget _buildScheduleStatus(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.scheduleStatus,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildScheduleItem(context, AppStrings.thisWeekInterview, '2건'),
            const Divider(),
            _buildScheduleItem(context, AppStrings.thisWeekAnnouncement, '1건'),
            const Divider(),
            _buildScheduleItem(context, AppStrings.thisWeekDeadline, '3건'),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, String label, String value) {
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

  int get totalApplications => _totalApplications;
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
