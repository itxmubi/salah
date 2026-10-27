import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'kaaba_marker.dart';

/// Unwrap the bearing so crossing north animates along the shortest arc.
class QiblaDirectionIndicator extends StatefulWidget {
  const QiblaDirectionIndicator({
    required this.bearing,
    required this.dialSize,
    required this.color,
    super.key,
  });
  final double bearing;
  final double dialSize;
  final Color color;
  @override
  State<QiblaDirectionIndicator> createState() =>
      _QiblaDirectionIndicatorState();
}

class _QiblaDirectionIndicatorState extends State<QiblaDirectionIndicator> {
  late double _angle = widget.bearing;
  @override
  void didUpdateWidget(QiblaDirectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _angle += (widget.bearing - _angle + 180) % 360 - 180;
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: _angle, end: _angle),
    duration: const Duration(milliseconds: 180),
    builder: (context, degrees, child) {
      final angle = degrees * math.pi / 180;
      final radius = widget.dialSize * 0.245;
      return SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: angle,
              child: Icon(
                Icons.navigation_rounded,
                size: 70,
                color: widget.color,
              ),
            ),
            Transform.translate(
              offset: Offset(
                math.sin(angle) * radius,
                -math.cos(angle) * radius,
              ),
              child: const KaabaMarker(key: ValueKey('qibla-kaaba')),
            ),
          ],
        ),
      );
    },
  );
}
