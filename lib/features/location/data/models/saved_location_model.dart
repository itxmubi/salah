import '../../domain/entities/saved_location.dart';

class SavedLocationModel {
  const SavedLocationModel({
    required this.id,
    required this.city,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isDeviceLocation,
  });

  final String id;
  final String city;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDeviceLocation;

  factory SavedLocationModel.fromEntity(SavedLocation location) =>
      SavedLocationModel(
        id: location.id,
        city: location.city,
        region: location.region,
        country: location.country,
        latitude: location.latitude,
        longitude: location.longitude,
        isDeviceLocation: location.isDeviceLocation,
      );

  factory SavedLocationModel.fromJson(Map<String, Object?> json) =>
      SavedLocationModel(
        id: json['id']! as String,
        city: json['city']! as String,
        region: json['region']! as String,
        country: json['country']! as String,
        latitude: (json['latitude']! as num).toDouble(),
        longitude: (json['longitude']! as num).toDouble(),
        isDeviceLocation: json['isDeviceLocation']! as bool,
      );

  SavedLocation toEntity() => SavedLocation(
    id: id,
    city: city,
    region: region,
    country: country,
    latitude: latitude,
    longitude: longitude,
    isDeviceLocation: isDeviceLocation,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'city': city,
    'region': region,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'isDeviceLocation': isDeviceLocation,
  };
}
