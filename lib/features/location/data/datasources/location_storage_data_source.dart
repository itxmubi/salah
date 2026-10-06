import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_location_model.dart';

class LocationStorageDataSource {
  LocationStorageDataSource(this._preferences);

  static const _savedLocationsKey = 'salah.location.saved.v1';
  static const _activeLocationKey = 'salah.location.active.v1';

  final SharedPreferencesAsync _preferences;

  Future<List<SavedLocationModel>> readSavedLocations() async {
    final encodedLocations = await _preferences.getStringList(
      _savedLocationsKey,
    );
    return (encodedLocations ?? const <String>[])
        .map(
          (json) => SavedLocationModel.fromJson(
            jsonDecode(json) as Map<String, Object?>,
          ),
        )
        .toList(growable: false);
  }

  Future<SavedLocationModel?> readActiveLocation() async {
    final json = await _preferences.getString(_activeLocationKey);
    if (json == null || json.isEmpty) return null;
    return SavedLocationModel.fromJson(
      jsonDecode(json) as Map<String, Object?>,
    );
  }

  Future<void> writeSavedLocations(List<SavedLocationModel> locations) async {
    await _preferences.setStringList(
      _savedLocationsKey,
      locations.map((location) => jsonEncode(location.toJson())).toList(),
    );
  }

  Future<void> writeActiveLocation(SavedLocationModel? location) async {
    if (location == null) {
      await _preferences.remove(_activeLocationKey);
    } else {
      await _preferences.setString(
        _activeLocationKey,
        jsonEncode(location.toJson()),
      );
    }
  }
}
