import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoldToSecureButton extends StatefulWidget {
  const HoldToSecureButton({
    required this.purchaseStatus,
    required this.enabled,
    required this.onHoldCompleted,
    super.key,
  });

  final PurchaseLifecycleStatus purchaseStatus;
  final bool enabled;
  final VoidCallback onHoldCompleted;

  @override
  State<HoldToSecureButton> createState() => _HoldToSecureButtonState();
}

class _HoldToSecureButtonState extends State<HoldToSecureButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  final Set<int> _hapticMilestones = <int>{};
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _holdController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(_onProgress)
          ..addStatusListener(_onStatusChanged);
  }

  @override
  void didUpdateWidget(covariant HoldToSecureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.purchaseStatus != PurchaseLifecycleStatus.idle &&
        oldWidget.purchaseStatus == PurchaseLifecycleStatus.idle) {
      _holdController.stop();
    }
  }

  void _onProgress() {
    final progress = _holdController.value;
    for (final milestone in <int>[25, 50, 75]) {
      if (progress >= milestone / 100 &&
          !_hapticMilestones.contains(milestone)) {
        HapticFeedback.selectionClick();
        _hapticMilestones.add(milestone);
      }
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_triggered) {
      _triggered = true;
      HapticFeedback.heavyImpact();
      widget.onHoldCompleted();
    }
  }

  void _startHold() {
    if (!widget.enabled ||
        widget.purchaseStatus != PurchaseLifecycleStatus.idle) {
      return;
    }
    _triggered = false;
    _hapticMilestones.clear();
    HapticFeedback.mediumImpact();
    _holdController
      ..reset()
      ..forward();
  }

  void _cancelHold() {
    if (_holdController.isAnimating && !_triggered) {
      _holdController.reverse();
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _holdController
      ..removeListener(_onProgress)
      ..removeStatusListener(_onStatusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseStatus = widget.purchaseStatus;

    return SizedBox(
      height: 74,
      width: double.infinity,
      child: GestureDetector(
        onTapDown: (_) => _startHold(),
        onTapUp: (_) => _cancelHold(),
        onTapCancel: _cancelHold,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _holdController,
          builder: (context, _) {
            return CustomPaint(
              painter: _ProgressRingPainter(progress: _holdController.value),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: purchaseStatus == PurchaseLifecycleStatus.success
                      ? const LinearGradient(
                          colors: <Color>[Color(0xFF48C78E), Color(0xFF3AA678)],
                        )
                      : const LinearGradient(
                          colors: <Color>[Color(0xFF2E3D58), Color(0xFF1C2535)],
                        ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 26,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _buildCenterContent(context, purchaseStatus),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCenterContent(
    BuildContext context,
    PurchaseLifecycleStatus status,
  ) {
    switch (status) {
      case PurchaseLifecycleStatus.idle:
        return Text(
          widget.enabled ? 'HOLD TO SECURE' : 'SOLD OUT',
          key: ValueKey<String>('idle-${widget.enabled}'),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: const Color(0xFFF8F4E8),
            fontSize: 17,
            letterSpacing: 1.1,
          ),
        );
      case PurchaseLifecycleStatus.verifying:
        return const SizedBox(
          key: ValueKey<String>('verifying'),
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2D7A2)),
          ),
        );
      case PurchaseLifecycleStatus.success:
        return const Icon(
          Icons.check_rounded,
          key: ValueKey<String>('success'),
          size: 34,
          color: Color(0xFFF4FFFC),
        );
    }
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.progress});

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
      ..strokeWidth = 5
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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
