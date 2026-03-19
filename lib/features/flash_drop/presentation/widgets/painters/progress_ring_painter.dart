import 'package:flutter/material.dart';

class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final outer = RRect.fromRectAndRadius(rect, const Radius.circular(22));

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x335F7598);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFF7DEAC), Color(0xFFE4B56A)],
      ).createShader(rect);

    canvas.drawRRect(outer.deflate(1), trackPaint);

    final path = Path()..addRRect(outer.deflate(1.5));
    final metrics = path.computeMetrics().first;
    final segment = metrics.extractPath(1, metrics.length * progress);
    canvas.drawPath(segment, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
