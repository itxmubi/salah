import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  ThemeSettings build() {
    _restore();
    return const ThemeSettings(
      mode: ThemeMode.system,
      seedColor: AppColors.forest,
    );
  }

  Future<void> _restore() async {
    final modeIndex = await _preferences.getInt('appearance.mode');
    final colorValue = await _preferences.getInt('appearance.seedColor');
    if (!ref.mounted) return;
    state = state.copyWith(
      mode:
          modeIndex != null &&
              modeIndex >= 0 &&
              modeIndex < ThemeMode.values.length
          ? ThemeMode.values[modeIndex]
          : null,
      seedColor: colorValue == null ? null : Color(colorValue),
    );
  }

  void setMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
    _preferences.setInt('appearance.mode', mode.index);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    _preferences.setInt('appearance.seedColor', color.toARGB32());
  }
}
