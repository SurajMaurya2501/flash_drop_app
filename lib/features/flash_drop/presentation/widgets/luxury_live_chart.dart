import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/entities/historical_bid_point.dart';

class LuxuryLiveChart extends StatefulWidget {
  const LuxuryLiveChart({
    required this.historicalSeries,
    required this.liveSeries,
    super.key,
  });

  final List<HistoricalBidPoint> historicalSeries;
  final List<HistoricalBidPoint> liveSeries;

  @override
  State<LuxuryLiveChart> createState() => _LuxuryLiveChartState();
}

class _LuxuryLiveChartState extends State<LuxuryLiveChart>
    with TickerProviderStateMixin {
  late final AnimationController _historyRevealController;
  late final AnimationController _liveTickController;
  double _fromLivePrice = 0;
  double _toLivePrice = 0;

  @override
  void initState() {
    super.initState();
    _historyRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      value: widget.historicalSeries.isNotEmpty ? 1 : 0,
    );
    _liveTickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1,
    );

    if (widget.historicalSeries.isNotEmpty) {
      _historyRevealController.forward(from: 0);
    }

    if (widget.liveSeries.isNotEmpty) {
      final last = widget.liveSeries.last.price;
      _fromLivePrice = last;
      _toLivePrice = last;
    }
  }

  @override
  void didUpdateWidget(covariant LuxuryLiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.historicalSeries.isEmpty &&
        widget.historicalSeries.isNotEmpty) {
      _historyRevealController.forward(from: 0);
    }

    if (widget.liveSeries.isEmpty) {
      return;
    }

    final newLast = widget.liveSeries.last.price;
    final previousLast = oldWidget.liveSeries.isNotEmpty
        ? oldWidget.liveSeries.last.price
        : newLast;

    if (newLast != previousLast) {
      _fromLivePrice = previousLast;
      _toLivePrice = newLast;
      _liveTickController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _historyRevealController.dispose();
    _liveTickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _historyRevealController,
          _liveTickController,
        ]),
        builder: (context, _) {
          final animatedLastLivePrice = widget.liveSeries.isEmpty
              ? null
              : ui.lerpDouble(
                  _fromLivePrice,
                  _toLivePrice,
                  Curves.easeOutCubic.transform(_liveTickController.value),
                );

          return CustomPaint(
            painter: _LuxuryLineChartPainter(
              historicalSeries: widget.historicalSeries,
              liveSeries: widget.liveSeries,
              historyRevealProgress: _historyRevealController.value,
              animatedLastLivePrice: animatedLastLivePrice,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _LuxuryLineChartPainter extends CustomPainter {
  const _LuxuryLineChartPainter({
    required this.historicalSeries,
    required this.liveSeries,
    required this.historyRevealProgress,
    required this.animatedLastLivePrice,
  });

  final List<HistoricalBidPoint> historicalSeries;
  final List<HistoricalBidPoint> liveSeries;
  final double historyRevealProgress;
  final double? animatedLastLivePrice;

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

    final totalPoints = historicalSeries.length + liveSeries.length;
    if (totalPoints < 2) {
      return;
    }

    final mergedPrices = <double>[
      ...historicalSeries.map((e) => e.price),
      ...liveSeries.map((e) => e.price),
    ];

    if (animatedLastLivePrice != null && mergedPrices.isNotEmpty) {
      mergedPrices[mergedPrices.length - 1] = animatedLastLivePrice!;
    }

    final minPrice = mergedPrices.reduce(math.min);
    final maxPrice = mergedPrices.reduce(math.max);
    final priceRange = math.max(1.0, maxPrice - minPrice);
    const leftPadding = 14.0;
    const rightPadding = 14.0;
    const topPadding = 12.0;
    const bottomPadding = 12.0;
    final drawWidth = size.width - leftPadding - rightPadding;
    final drawHeight = size.height - topPadding - bottomPadding;

    Offset pointOffset(int globalIndex, double pointPrice) {
      final x = leftPadding + (globalIndex / (totalPoints - 1)) * drawWidth;
      final normalized = (pointPrice - minPrice) / priceRange;
      final y = topPadding + (1 - normalized) * drawHeight;
      return Offset(x, y);
    }

    final historicalPath = Path();
    if (historicalSeries.length > 1) {
      for (int i = 0; i < historicalSeries.length; i++) {
        final offset = pointOffset(i, historicalSeries[i].price);
        if (i == 0) {
          historicalPath.moveTo(offset.dx, offset.dy);
        } else {
          historicalPath.lineTo(offset.dx, offset.dy);
        }
      }
    }

    final livePath = Path();
    if (liveSeries.isNotEmpty) {
      if (historicalSeries.isNotEmpty) {
        final anchor = pointOffset(
          historicalSeries.length - 1,
          historicalSeries.last.price,
        );
        livePath.moveTo(anchor.dx, anchor.dy);
      }

      for (int i = 0; i < liveSeries.length; i++) {
        final globalIndex = historicalSeries.length + i;
        final isLast = i == liveSeries.length - 1;
        final price = isLast && animatedLastLivePrice != null
            ? animatedLastLivePrice!
            : liveSeries[i].price;
        final offset = pointOffset(globalIndex, price);

        if (i == 0 && historicalSeries.isEmpty) {
          livePath.moveTo(offset.dx, offset.dy);
        } else {
          livePath.lineTo(offset.dx, offset.dy);
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

    if (historicalPath.computeMetrics().isNotEmpty) {
      final historyMetric = historicalPath.computeMetrics().first;
      final historyLength = historyMetric.length * historyRevealProgress;
      final revealedHistoryPath = historyMetric.extractPath(0, historyLength);
      canvas.drawPath(revealedHistoryPath, historicalPaint);
    }

    if (livePath.computeMetrics().isNotEmpty) {
      canvas.drawPath(livePath, livePaint);
    }

    final hasLive = liveSeries.isNotEmpty;
    final lastPrice = hasLive
        ? (animatedLastLivePrice ?? liveSeries.last.price)
        : historicalSeries.last.price;
    final lastIndex = hasLive ? totalPoints - 1 : historicalSeries.length - 1;
    final marker = pointOffset(lastIndex, lastPrice);

    final markerPaint = Paint()
      ..color = const Color(0xFFF0CB8B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(marker, 4.2, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _LuxuryLineChartPainter oldDelegate) {
    return oldDelegate.historicalSeries != historicalSeries ||
        oldDelegate.liveSeries != liveSeries ||
        oldDelegate.historyRevealProgress != historyRevealProgress ||
        oldDelegate.animatedLastLivePrice != animatedLastLivePrice;
  }
}
