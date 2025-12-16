// Phase 9-2: 선 그래프 페인터
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

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

