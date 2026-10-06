import '../../../../core/utils/result.dart';
import '../entities/location_issue.dart';
import '../entities/location_snapshot.dart';
import '../entities/saved_location.dart';
import '../repositories/location_repository.dart';

class LoadLocations {
  const LoadLocations(this._repository);
  final LocationRepository _repository;

  Future<Result<LocationSnapshot>> call() => _repository.loadSnapshot();
}

class GetCurrentLocation {
  const GetCurrentLocation(this._repository);
  final LocationRepository _repository;

  Future<Result<SavedLocation>> call() => _repository.getCurrentLocation();
}

class SearchCities {
  const SearchCities(this._repository);
  final LocationRepository _repository;

  Future<Result<List<SavedLocation>>> call(String query) =>
      _repository.searchCity(query);
}

class SetActiveLocation {
  const SetActiveLocation(this._repository);
  final LocationRepository _repository;

  Future<Result<LocationSnapshot>> call(SavedLocation location) =>
      _repository.setActiveLocation(location);
}

class SaveLocation {
  const SaveLocation(this._repository);
  final LocationRepository _repository;

  Future<Result<LocationSnapshot>> call(SavedLocation location) =>
      _repository.saveLocation(location);
}

class RemoveSavedLocation {
  const RemoveSavedLocation(this._repository);
  final LocationRepository _repository;

  Future<Result<LocationSnapshot>> call(String id) =>
      _repository.removeSavedLocation(id);
}

class OpenLocationSettings {
  const OpenLocationSettings(this._repository);
  final LocationRepository _repository;

  Future<void> call(LocationIssue issue) => _repository.openSettings(issue);
}
