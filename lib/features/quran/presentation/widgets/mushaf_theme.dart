import 'package:flutter/material.dart';

/// Reading colors are independent of the app's accent color.
@immutable
class MushafTheme {
  const MushafTheme({
    required this.background,
    required this.text,
    required this.border,
    required this.highlight,
    required this.bannerFill,
    required this.secondaryText,
  });

  final Color background;
  final Color text;
  final Color border;
  final Color highlight;
  final Color bannerFill;
  final Color secondaryText;

  static const fontFamily = 'AmiriQuran';

  static const light = MushafTheme(
    background: Color(0xFFFBF6E9),
    text: Color(0xFF30291F),
    border: Color(0xFFA78C54),
    highlight: Color(0xFFF5E9A8),
    bannerFill: Color(0xFFF3EBD3),
    secondaryText: Color(0xFF766A56),
  );

  static const dark = MushafTheme(
    background: Color(0xFF24221D),
    text: Color(0xFFEEE3CC),
    border: Color(0xFFAC9460),
    highlight: Color(0xFF63542D),
    bannerFill: Color(0xFF343026),
    secondaryText: Color(0xFFC0AF8F),
  );

  static const sepia = MushafTheme(
    background: Color(0xFFEEE0C4),
    text: Color(0xFF433321),
    border: Color(0xFF917542),
    highlight: Color(0xFFE8CE87),
    bannerFill: Color(0xFFE2D0A9),
    secondaryText: Color(0xFF756044),
  );

  static MushafTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
