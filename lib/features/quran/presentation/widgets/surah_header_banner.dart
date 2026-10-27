import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mushaf_theme.dart';

class SurahHeaderBanner extends StatelessWidget {
  const SurahHeaderBanner({
    required this.surahNameArabic,
    this.palette,
    super.key,
  });

  final String surahNameArabic;
  final MushafTheme? palette;

  @override
  Widget build(BuildContext context) {
    final colors = palette ?? MushafTheme.of(context);
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(
        painter: _SurahBannerPainter(colors),
        child: Padding(
          // The title can wrap at large text scales; no fixed height clips it.
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          child: Text(
            surahNameArabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MushafTheme.fontFamily,
              fontSize: 25,
              height: 1.8,
              color: colors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahBannerPainter extends CustomPainter {
  const _SurahBannerPainter(this.palette);

  final MushafTheme palette;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(1), const Radius.circular(3)),
      Paint()..color = palette.bannerFill,
    );
    final outline = Paint()
      ..color = palette.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(1), const Radius.circular(3)),
      outline,
    );
    canvas.drawRect(bounds.deflate(5), outline..strokeWidth = 0.6);

    // Interlaced eight-point stars and diamond rails echo a printed headpiece.
    for (final x in [20.0, size.width - 20]) {
      final center = Offset(x, size.height / 2);
      for (final angle in [0.0, math.pi / 4]) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 15, height: 15),
          outline,
        );
        canvas.restore();
      }
      canvas.drawCircle(center, 3, outline);
    }
    for (final y in [8.0, size.height - 8]) {
      for (var x = 34.0; x < size.width - 30; x += 12) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 3, y)
            ..lineTo(x, y - 2)
            ..lineTo(x + 3, y)
            ..lineTo(x, y + 2)
            ..close(),
          outline,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SurahBannerPainter oldDelegate) =>
      palette != oldDelegate.palette;
}
