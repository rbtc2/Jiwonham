// Phase 9-2: 상태별 선 그래프 페인터
import 'package:flutter/material.dart';

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

