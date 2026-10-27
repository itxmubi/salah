import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

class AppSettings {
  const AppSettings({this.language, this.setupComplete = false});
  final String? language;
  final bool setupComplete;
  Locale? get locale => language == null ? null : Locale(language!);
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = ref.watch(appPreferencesProvider);
    try {
      final language = await prefs.getString('app.language');
      final complete = await prefs.getBool('app.setupComplete') ?? false;
      return AppSettings(
        language: ['ar', 'en'].contains(language) ? language : null,
        setupComplete: complete,
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> setLanguage(String? value) async {
    final prefs = ref.read(appPreferencesProvider);
    if (value == null) {
      await prefs.remove('app.language');
    } else {
      await prefs.setString('app.language', value);
    }
    if (!ref.mounted) return;
    state = AsyncData(
      AppSettings(
        language: value,
        setupComplete: state.asData?.value.setupComplete ?? false,
      ),
    );
  }

  Future<void> completeSetup() async {
    await ref.read(appPreferencesProvider).setBool('app.setupComplete', true);
    if (!ref.mounted) return;
    state = AsyncData(
      AppSettings(language: state.asData?.value.language, setupComplete: true),
    );
  }
}
