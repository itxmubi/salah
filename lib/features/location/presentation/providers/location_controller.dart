import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart' as core;
import '../../domain/entities/location_issue.dart';
import '../../domain/entities/location_snapshot.dart';
import '../../domain/entities/saved_location.dart';
import 'location_providers.dart';

class LocationState {
  const LocationState({
    this.snapshot = const LocationSnapshot(),
    this.searchResults = const [],
    this.issue,
    this.isLocating = false,
    this.isSearching = false,
    this.isUpdating = false,
  });

  final LocationSnapshot snapshot;
  final List<SavedLocation> searchResults;
  final LocationIssue? issue;
  final bool isLocating;
  final bool isSearching;
  final bool isUpdating;

  LocationState copyWith({
    LocationSnapshot? snapshot,
    List<SavedLocation>? searchResults,
    LocationIssue? issue,
    bool clearIssue = false,
    bool? isLocating,
    bool? isSearching,
    bool? isUpdating,
  }) => LocationState(
    snapshot: snapshot ?? this.snapshot,
    searchResults: searchResults ?? this.searchResults,
    issue: clearIssue ? null : issue ?? this.issue,
    isLocating: isLocating ?? this.isLocating,
    isSearching: isSearching ?? this.isSearching,
    isUpdating: isUpdating ?? this.isUpdating,
  );
}

class LocationController extends AsyncNotifier<LocationState> {
  @override
  Future<LocationState> build() async {
    final result = await ref.watch(loadLocationsProvider)();
    if (result is core.Success<LocationSnapshot>) {
      return LocationState(snapshot: result.value);
    }
    final error = (result as core.Error<LocationSnapshot>).error;
    return LocationState(issue: _toIssue(error));
  }

  Future<void> loadCurrentLocation() async {
    _update(isLocating: true, clearIssue: true);
    final result = await ref.read(getCurrentLocationProvider)();
    if (result is core.Success<SavedLocation>) {
      await setActiveLocation(result.value);
    } else {
      _update(
        isLocating: false,
        issue: _toIssue((result as core.Error<SavedLocation>).error),
      );
    }
  }

  Future<void> searchCity(String query) async {
    if (query.trim().isEmpty) {
      _update(
        isSearching: false,
        issue: LocationIssue.noSearchResults,
        searchResults: const [],
      );
      return;
    }
    _update(isSearching: true, clearIssue: true, searchResults: const []);
    final result = await ref.read(searchCitiesProvider)(query.trim());
    if (result is core.Success<List<SavedLocation>>) {
      _update(isSearching: false, searchResults: result.value);
    } else {
      _update(
        isSearching: false,
        issue: _toIssue((result as core.Error<List<SavedLocation>>).error),
        searchResults: const [],
      );
    }
  }

  Future<void> setActiveLocation(SavedLocation location) async {
    _update(isLocating: false, isUpdating: true, clearIssue: true);
    final result = await ref.read(setActiveLocationProvider)(location);
    _applySnapshotResult(result);
  }

  Future<void> saveLocation(SavedLocation location) async {
    _update(isUpdating: true, clearIssue: true);
    final result = await ref.read(saveLocationProvider)(location);
    _applySnapshotResult(result);
  }

  Future<void> removeSavedLocation(String id) async {
    _update(isUpdating: true, clearIssue: true);
    final result = await ref.read(removeSavedLocationProvider)(id);
    _applySnapshotResult(result);
  }

  Future<void> openSettings() async {
    final issue = state.asData?.value.issue;
    if (issue == null) return;
    try {
      await ref.read(openLocationSettingsProvider)(issue);
    } catch (_) {
      _update(issue: LocationIssue.unknown);
    }
  }

  Future<void> refresh() async {
    _update(isUpdating: true, clearIssue: true);
    final result = await ref.read(loadLocationsProvider)();
    _applySnapshotResult(result);
  }

  void _applySnapshotResult(core.Result<LocationSnapshot> result) {
    if (result is core.Success<LocationSnapshot>) {
      _update(
        snapshot: result.value,
        searchResults: const [],
        isLocating: false,
        isSearching: false,
        isUpdating: false,
        clearIssue: true,
      );
    } else {
      _update(
        isLocating: false,
        isSearching: false,
        isUpdating: false,
        issue: _toIssue((result as core.Error<LocationSnapshot>).error),
      );
    }
  }

  void _update({
    LocationSnapshot? snapshot,
    List<SavedLocation>? searchResults,
    LocationIssue? issue,
    bool clearIssue = false,
    bool? isLocating,
    bool? isSearching,
    bool? isUpdating,
  }) {
    final current = state.asData?.value ?? const LocationState();
    state = AsyncData(
      current.copyWith(
        snapshot: snapshot,
        searchResults: searchResults,
        issue: issue,
        clearIssue: clearIssue,
        isLocating: isLocating,
        isSearching: isSearching,
        isUpdating: isUpdating,
      ),
    );
  }

  LocationIssue _toIssue(Object error) =>
      error is LocationIssue ? error : LocationIssue.unknown;
}

final locationControllerProvider =
    AsyncNotifierProvider<LocationController, LocationState>(
      LocationController.new,
    );

final activeLocationProvider = Provider<SavedLocation?>((ref) =>
    ref.watch(
      locationControllerProvider.select(
        (asyncState) => asyncState.asData?.value.snapshot.activeLocation,
      ),
    ));
