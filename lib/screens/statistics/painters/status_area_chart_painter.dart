// Phase 9-2: 상태별 영역 차트 페인터
import 'package:flutter/material.dart';

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

