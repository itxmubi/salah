import 'package:flutter/material.dart';

import 'mushaf_theme.dart';

/// A vector frame stays sharp at phone and tablet sizes without image assets.
class MushafPageBorder extends StatelessWidget {
  const MushafPageBorder({
    required this.child,
    this.palette,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final MushafTheme? palette;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = palette ?? MushafTheme.of(context);
    return ColoredBox(
      color: colors.background,
      child: CustomPaint(
        foregroundPainter: _PageFramePainter(colors.border),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _PageFramePainter extends CustomPainter {
  const _PageFramePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(1), const Radius.circular(10)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(6), const Radius.circular(6)),
      paint..strokeWidth = 0.6,
    );

    // Small lozenges decorate the corners without competing with the text.
    for (final x in [11.0, size.width - 11]) {
      for (final y in [11.0, size.height - 11]) {
        canvas.drawPath(
          Path()
            ..moveTo(x, y - 4)
            ..lineTo(x + 4, y)
            ..lineTo(x, y + 4)
            ..lineTo(x - 4, y)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PageFramePainter oldDelegate) =>
      color != oldDelegate.color;
}
