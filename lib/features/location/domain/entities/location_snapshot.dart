import 'saved_location.dart';

class LocationSnapshot {
  const LocationSnapshot({this.activeLocation, this.savedLocations = const []});

  final SavedLocation? activeLocation;
  final List<SavedLocation> savedLocations;
}
