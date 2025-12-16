// Phase 9-2: 그리드 라인 페인터
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

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

