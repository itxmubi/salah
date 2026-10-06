import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';

class ThemeSettings {
  const ThemeSettings({required this.mode, required this.seedColor});

  final ThemeMode mode;
  final Color seedColor;

  ThemeSettings copyWith({ThemeMode? mode, Color? seedColor}) => ThemeSettings(
    mode: mode ?? this.mode,
    seedColor: seedColor ?? this.seedColor,
  );
}

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsController, ThemeSettings>(
      ThemeSettingsController.new,
    );

class ThemeSettingsController extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() =>
      const ThemeSettings(mode: ThemeMode.system, seedColor: AppColors.forest);

  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);

  void setSeedColor(Color color) => state = state.copyWith(seedColor: color);
}
