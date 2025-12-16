// Phase 9-2: 원형 차트 페인터
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

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

