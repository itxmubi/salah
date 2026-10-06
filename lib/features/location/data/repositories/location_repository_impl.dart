import '../../../../core/utils/result.dart' as core;
import '../../domain/entities/location_issue.dart';
import '../../domain/entities/location_snapshot.dart';
import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_storage_data_source.dart';
import '../datasources/native_location_data_source.dart';
import '../models/saved_location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({
    required NativeLocationDataSource device,
    required LocationStorageDataSource storage,
  }) : _device = device,
       _storage = storage;

  final NativeLocationDataSource _device;
  final LocationStorageDataSource _storage;

  @override
  Future<core.Result<LocationSnapshot>> loadSnapshot() =>
      _guard(_readSnapshot, LocationIssue.storageFailure);

  @override
  Future<core.Result<SavedLocation>> getCurrentLocation() => _guard(
    _device.getCurrentLocation,
    LocationIssue.currentLocationUnavailable,
  );

  @override
  Future<core.Result<List<SavedLocation>>> searchCity(String query) => _guard(
    () async => (await _device.searchCity(query)).toList(growable: false),
    LocationIssue.searchFailed,
  );

  @override
  Future<core.Result<LocationSnapshot>> setActiveLocation(
    SavedLocation location,
  ) => _guard(() async {
    await _storage.writeActiveLocation(SavedLocationModel.fromEntity(location));
    return _readSnapshot();
  }, LocationIssue.storageFailure);

  @override
  Future<core.Result<LocationSnapshot>> saveLocation(SavedLocation location) =>
      _guard(() async {
        final saved = await _storage.readSavedLocations();
        final model = SavedLocationModel.fromEntity(
          SavedLocation(
            id: location.id,
            city: location.city,
            region: location.region,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        );
        final updated = [...saved.where((item) => item.id != model.id), model];
        await _storage.writeSavedLocations(updated);
        return _readSnapshot();
      }, LocationIssue.storageFailure);

  @override
  Future<core.Result<LocationSnapshot>> removeSavedLocation(String id) =>
      _guard(() async {
        final saved = await _storage.readSavedLocations();
        final updated = saved.where((item) => item.id != id).toList();
        await _storage.writeSavedLocations(updated);
        final active = await _storage.readActiveLocation();
        if (active?.id == id) {
          await _storage.writeActiveLocation(
            updated.isEmpty ? null : updated.first,
          );
        }
        return _readSnapshot();
      }, LocationIssue.storageFailure);

  @override
  Future<void> openSettings(LocationIssue issue) => _device.openSettings(issue);

  Future<LocationSnapshot> _readSnapshot() async {
    final saved = await _storage.readSavedLocations();
    final active = await _storage.readActiveLocation();
    return LocationSnapshot(
      activeLocation: active?.toEntity(),
      savedLocations: saved.map((location) => location.toEntity()).toList(),
    );
  }

  Future<core.Result<T>> _guard<T>(
    Future<T> Function() action,
    LocationIssue fallback,
  ) async {
    try {
      return core.Success(await action());
    } on LocationSourceException catch (error) {
      return core.Error(error.issue);
    } on FormatException {
      return core.Error(LocationIssue.storageFailure);
    } catch (_) {
      return core.Error(fallback);
    }
  }
}
