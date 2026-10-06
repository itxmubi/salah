class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.city,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isDeviceLocation = false,
  });

  final String id;
  final String city;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDeviceLocation;
}
