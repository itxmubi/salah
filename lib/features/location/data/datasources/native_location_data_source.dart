import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_issue.dart';
import '../../domain/entities/saved_location.dart';

class LocationSourceException implements Exception {
  const LocationSourceException(this.issue);

  final LocationIssue issue;
}

class NativeLocationDataSource {
  NativeLocationDataSource({Geocoding? geocoding})
    : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;

  Future<SavedLocation> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationSourceException(LocationIssue.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationSourceException(
        LocationIssue.permissionPermanentlyDenied,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationSourceException(LocationIssue.permissionDenied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      var city = '';
      var region = '';
      var country = '';
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = _firstNonEmpty([
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
          ]);
          region = place.administrativeArea ?? '';
          country = place.country ?? '';
        }
      } on PlatformException {
        // Keep the coordinates usable if reverse geocoding is unavailable.
      } on TimeoutException {
        // Keep the coordinates usable if the platform geocoder times out.
      }
      return SavedLocation(
        id: _idFor(position.latitude, position.longitude),
        city: city,
        region: region,
        country: country,
        latitude: position.latitude,
        longitude: position.longitude,
        isDeviceLocation: true,
      );
    } on TimeoutException {
      throw const LocationSourceException(
        LocationIssue.currentLocationUnavailable,
      );
    } on LocationServiceDisabledException {
      throw const LocationSourceException(LocationIssue.serviceDisabled);
    } on PermissionDeniedException {
      throw const LocationSourceException(LocationIssue.permissionDenied);
    } on PlatformException {
      throw const LocationSourceException(
        LocationIssue.currentLocationUnavailable,
      );
    }
  }

  Future<List<SavedLocation>> searchCity(String query) async {
    final coordinates = await _geocoding.locationFromAddress(query);
    if (coordinates.isEmpty) {
      throw const LocationSourceException(LocationIssue.noSearchResults);
    }

    final results = <SavedLocation>[];
    for (final coordinate in coordinates.take(5)) {
      String city = query.trim();
      var region = '';
      var country = '';
      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          coordinate.latitude,
          coordinate.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = _firstNonEmpty([
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
            query,
          ]);
          region = place.administrativeArea ?? '';
          country = place.country ?? '';
        }
      } on PlatformException {
        // The searched text remains a useful label if reverse lookup fails.
      } on TimeoutException {
        // The searched text remains a useful label if reverse lookup times out.
      }
      results.add(
        SavedLocation(
          id: _idFor(coordinate.latitude, coordinate.longitude),
          city: city,
          region: region,
          country: country,
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
        ),
      );
    }
    return results;
  }

  Future<void> openSettings(LocationIssue issue) async {
    if (issue == LocationIssue.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  String _firstNonEmpty(List<String?> candidates) => candidates
      .whereType<String>()
      .map((value) => value.trim())
      .firstWhere((value) => value.isNotEmpty, orElse: () => '');

  String _idFor(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(4)}:${longitude.toStringAsFixed(4)}';
}
