import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import 'mushaf_theme.dart';

String arabicIndicDigits(int number) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return number
      .toString()
      .split('')
      .map((digit) => digits[int.parse(digit)])
      .join();
}

class AyahEndMarker extends StatelessWidget {
  const AyahEndMarker({
    required this.number,
    this.isHighlighted = false,
    this.onTap,
    this.palette,
    super.key,
  });

  final int number;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final MushafTheme? palette;

  @override
  Widget build(BuildContext context) {
    final colors = palette ?? MushafTheme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final diameter = (number >= 100 ? 48.0 : 44.0) * scale;
    return Semantics(
      label: AppLocalizations.of(context).quranAyahNumber(number),
      selected: isHighlighted,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: diameter,
          height: diameter,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHighlighted ? colors.highlight : colors.background,
            border: Border.all(color: colors.border),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.border.withValues(alpha: 0.55),
                width: 0.6,
              ),
            ),
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  arabicIndicDigits(number),
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: MushafTheme.fontFamily,
                    fontSize: 16,
                    height: 1,
                    color: colors.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
