// Phase 9-2: 영역 차트 페인터
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

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

