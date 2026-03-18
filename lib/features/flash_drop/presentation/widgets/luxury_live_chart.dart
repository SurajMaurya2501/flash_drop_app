import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/historical_bid_point.dart';

class LuxuryLiveChart extends StatelessWidget {
  const LuxuryLiveChart({
    required this.historicalSeries,
    required this.liveSeries,
    super.key,
  });

  final List<HistoricalBidPoint> historicalSeries;
  final List<HistoricalBidPoint> liveSeries;

  @override
  Widget build(BuildContext context) {
    final mergedSeries = <HistoricalBidPoint>[
      ...historicalSeries,
      ...liveSeries,
    ];

    return RepaintBoundary(
      child: CustomPaint(
        painter: _LuxuryLineChartPainter(
          historicalSeries: historicalSeries,
          mergedSeries: mergedSeries,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LuxuryLineChartPainter extends CustomPainter {
  const _LuxuryLineChartPainter({
    required this.historicalSeries,
    required this.mergedSeries,
  });

  final List<HistoricalBidPoint> historicalSeries;
  final List<HistoricalBidPoint> mergedSeries;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFF0F1722), Color(0xFF0A1118)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      backgroundPaint,
    );

    if (mergedSeries.length < 2) {
      return;
    }

    final minPrice = mergedSeries.map((point) => point.price).reduce(math.min);
    final maxPrice = mergedSeries.map((point) => point.price).reduce(math.max);
    final priceRange = math.max(1.0, maxPrice - minPrice);
    final leftPadding = 14.0;
    final rightPadding = 14.0;
    final topPadding = 12.0;
    final bottomPadding = 12.0;
    final drawWidth = size.width - leftPadding - rightPadding;
    final drawHeight = size.height - topPadding - bottomPadding;

    final historicalPath = Path();
    final mergedPath = Path();

    for (int i = 0; i < mergedSeries.length; i++) {
      final point = mergedSeries[i];
      final x = leftPadding + (i / (mergedSeries.length - 1)) * drawWidth;
      final normalized = (point.price - minPrice) / priceRange;
      final y = topPadding + (1 - normalized) * drawHeight;

      if (i == 0) {
        mergedPath.moveTo(x, y);
      } else {
        mergedPath.lineTo(x, y);
      }
    }

    if (historicalSeries.length > 1) {
      for (int i = 0; i < historicalSeries.length; i++) {
        final point = historicalSeries[i];
        final x = leftPadding + (i / (mergedSeries.length - 1)) * drawWidth;
        final normalized = (point.price - minPrice) / priceRange;
        final y = topPadding + (1 - normalized) * drawHeight;

        if (i == 0) {
          historicalPath.moveTo(x, y);
        } else {
          historicalPath.lineTo(x, y);
        }
      }
    }

    final historicalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0x6681A5D7)
      ..isAntiAlias = true;

    final livePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFD9B77E), Color(0xFF66F3B9)],
      ).createShader(rect)
      ..isAntiAlias = true;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x22FFFFFF);

    for (int i = 1; i <= 3; i++) {
      final y = topPadding + (drawHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    canvas.drawPath(historicalPath, historicalPaint);
    canvas.drawPath(mergedPath, livePaint);

    final lastPoint = mergedSeries.last;
    final normalized = (lastPoint.price - minPrice) / priceRange;
    final markerY = topPadding + (1 - normalized) * drawHeight;
    final markerX = size.width - rightPadding;

    final markerPaint = Paint()
      ..color = const Color(0xFFF0CB8B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(markerX, markerY), 4.2, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _LuxuryLineChartPainter oldDelegate) {
    return oldDelegate.historicalSeries != historicalSeries ||
        oldDelegate.mergedSeries != mergedSeries;
  }
}
