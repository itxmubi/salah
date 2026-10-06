import 'dart:math' as math;

class QiblaDirection {
  const QiblaDirection({
    required this.bearingDegrees,
    required this.distanceKm,
  });

  static const kaabaLatitude = 21.4225;
  static const kaabaLongitude = 39.8262;
  static const earthRadiusKm = 6371.0088;

  final double bearingDegrees;
  final double distanceKm;

  factory QiblaDirection.fromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    final lat1 = _radians(latitude);
    final lat2 = _radians(kaabaLatitude);
    final deltaLongitude = _radians(kaabaLongitude - longitude);

    final y = math.sin(deltaLongitude) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);
    final bearing = (math.atan2(y, x) * 180 / math.pi + 360) % 360;

    final deltaLatitude = lat2 - lat1;
    final haversine =
        math.pow(math.sin(deltaLatitude / 2), 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.pow(math.sin(deltaLongitude / 2), 2);
    final clampedHaversine = haversine.clamp(0, 1).toDouble();
    final centralAngle =
        2 *
        math.atan2(
          math.sqrt(clampedHaversine),
          math.sqrt(1 - clampedHaversine),
        );

    return QiblaDirection(
      bearingDegrees: bearing,
      distanceKm: earthRadiusKm * centralAngle,
    );
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
