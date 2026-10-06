import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/location_storage_data_source.dart';
import '../../data/datasources/native_location_data_source.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/location_use_cases.dart';

final sharedPreferencesAsyncProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final nativeLocationDataSourceProvider = Provider<NativeLocationDataSource>(
  (ref) => NativeLocationDataSource(),
);

final locationStorageDataSourceProvider = Provider<LocationStorageDataSource>(
  (ref) => LocationStorageDataSource(ref.watch(sharedPreferencesAsyncProvider)),
);

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepositoryImpl(
    device: ref.watch(nativeLocationDataSourceProvider),
    storage: ref.watch(locationStorageDataSourceProvider),
  ),
);

final loadLocationsProvider = Provider<LoadLocations>(
  (ref) => LoadLocations(ref.watch(locationRepositoryProvider)),
);

final getCurrentLocationProvider = Provider<GetCurrentLocation>(
  (ref) => GetCurrentLocation(ref.watch(locationRepositoryProvider)),
);

final searchCitiesProvider = Provider<SearchCities>(
  (ref) => SearchCities(ref.watch(locationRepositoryProvider)),
);

final setActiveLocationProvider = Provider<SetActiveLocation>(
  (ref) => SetActiveLocation(ref.watch(locationRepositoryProvider)),
);

final saveLocationProvider = Provider<SaveLocation>(
  (ref) => SaveLocation(ref.watch(locationRepositoryProvider)),
);

final removeSavedLocationProvider = Provider<RemoveSavedLocation>(
  (ref) => RemoveSavedLocation(ref.watch(locationRepositoryProvider)),
);

final openLocationSettingsProvider = Provider<OpenLocationSettings>(
  (ref) => OpenLocationSettings(ref.watch(locationRepositoryProvider)),
);
