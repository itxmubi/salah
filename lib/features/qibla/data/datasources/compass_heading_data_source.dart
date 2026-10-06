import 'package:flutter_compass/flutter_compass.dart';

class CompassHeadingDataSource {
  const CompassHeadingDataSource();

  Stream<double?> get headings {
    final events = FlutterCompass.events;
    if (events == null) return Stream<double?>.value(null);
    return events.map((event) => event.heading).distinct();
  }
}
