// Phase 9-2: 스택 영역 차트 페인터 (누적 모드)
import 'package:flutter/material.dart';
import '../../../models/application_status.dart';

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

