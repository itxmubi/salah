import '../../../../core/utils/result.dart';
import '../entities/location_issue.dart';
import '../entities/location_snapshot.dart';
import '../entities/saved_location.dart';

abstract interface class LocationRepository {
  Future<Result<LocationSnapshot>> loadSnapshot();

  Future<Result<SavedLocation>> getCurrentLocation();

  Future<Result<List<SavedLocation>>> searchCity(String query);

  Future<Result<LocationSnapshot>> setActiveLocation(SavedLocation location);

  Future<Result<LocationSnapshot>> saveLocation(SavedLocation location);

  Future<Result<LocationSnapshot>> removeSavedLocation(String id);

  Future<void> openSettings(LocationIssue issue);
}
