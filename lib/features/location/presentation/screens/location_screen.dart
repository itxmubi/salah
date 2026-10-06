import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/location_issue.dart';
import '../../domain/entities/saved_location.dart';
import '../providers/location_controller.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final locationAsync = ref.watch(locationControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localization.locationTitle)),
      body: SafeArea(
        child: locationAsync.when(
          loading: () => Center(
            child: AppLoadingState(label: localization.loadingLocations),
          ),
          error: (error, stackTrace) => AppErrorState(
            title: localization.locationTitle,
            description: localization.locationUnknownError,
            retryLabel: localization.retry,
            onRetry: () =>
                ref.read(locationControllerProvider.notifier).refresh(),
          ),
          data: (locationState) => LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _buildContent(context, localization, locationState),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations localization,
    LocationState locationState,
  ) {
    final controller = ref.read(locationControllerProvider.notifier);
    final active = locationState.snapshot.activeLocation;
    final isActiveSaved =
        active != null &&
        locationState.snapshot.savedLocations.any(
          (item) => item.id == active.id,
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          localization.locationSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        if (locationState.issue case final issue?)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LocationIssueCard(
              issue: issue,
              localization: localization,
              onOpenSettings:
                  issue == LocationIssue.serviceDisabled ||
                      issue == LocationIssue.permissionPermanentlyDenied
                  ? controller.openSettings
                  : null,
            ),
          ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.activeLocation,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  child: Icon(
                    active?.isDeviceLocation == true
                        ? AppIcons.myLocation
                        : AppIcons.location,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(
                  active == null
                      ? localization.noActiveLocation
                      : _placeTitle(active, localization),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  active == null || _placeSubtitle(active).isEmpty
                      ? localization.currentLocationDescription
                      : _placeSubtitle(active),
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  AppButton(
                    label: localization.useCurrentLocation,
                    icon: AppIcons.myLocation,
                    onPressed:
                        locationState.isLocating || locationState.isUpdating
                        ? null
                        : controller.loadCurrentLocation,
                  ),
                  if (active != null && !isActiveSaved)
                    AppButton(
                      label: localization.saveCurrentLocation,
                      variant: AppButtonVariant.secondary,
                      icon: AppIcons.save,
                      onPressed: locationState.isUpdating
                          ? null
                          : () => controller.saveLocation(active),
                    ),
                ],
              ),
              if (locationState.isLocating) ...[
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(borderRadius: BorderRadius.circular(4)),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                localization.privacyLocationNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.searchCityTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: controller.searchCity,
                decoration: InputDecoration(
                  hintText: localization.searchCityHint,
                  prefixIcon: const Icon(AppIcons.search),
                  suffixIcon: IconButton(
                    tooltip: localization.search,
                    onPressed: locationState.isSearching
                        ? null
                        : () => controller.searchCity(_searchController.text),
                    icon: locationState.isSearching
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(AppIcons.search),
                  ),
                ),
              ),
              if (locationState.searchResults.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  localization.searchResults,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final result in locationState.searchResults)
                  _SearchResultTile(
                    location: result,
                    localization: localization,
                    isSaved: locationState.snapshot.savedLocations.any(
                      (saved) => saved.id == result.id,
                    ),
                    isUpdating: locationState.isUpdating,
                    onSelect: () => controller.setActiveLocation(result),
                    onSave: () => controller.saveLocation(result),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.savedLocations,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (locationState.snapshot.savedLocations.isEmpty)
                AppEmptyState(
                  title: localization.noSavedLocations,
                  description: localization.noSavedLocationsDescription,
                )
              else
                for (final saved in locationState.snapshot.savedLocations)
                  _SavedLocationTile(
                    location: saved,
                    localization: localization,
                    isActive: active?.id == saved.id,
                    isUpdating: locationState.isUpdating,
                    onSelect: () => controller.setActiveLocation(saved),
                    onRemove: () => controller.removeSavedLocation(saved.id),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  String _placeTitle(SavedLocation location, AppLocalizations localization) {
    if (location.isDeviceLocation) return localization.currentLocation;
    if (location.city.isEmpty) return localization.unknownCity;
    return location.city;
  }

  String _placeSubtitle(SavedLocation location) => [
    if (location.region.isNotEmpty && location.region != location.city)
      location.region,
    if (location.country.isNotEmpty) location.country,
  ].join(', ');
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.location,
    required this.localization,
    required this.isSaved,
    required this.isUpdating,
    required this.onSelect,
    required this.onSave,
  });

  final SavedLocation location;
  final AppLocalizations localization;
  final bool isSaved;
  final bool isUpdating;
  final VoidCallback onSelect;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(AppIcons.location),
    title: Text(location.city),
    subtitle: Text(
      [
        if (location.region.isNotEmpty) location.region,
        if (location.country.isNotEmpty) location.country,
      ].join(', '),
    ),
    onTap: isUpdating ? null : onSelect,
    trailing: IconButton(
      tooltip: isSaved ? localization.alreadySaved : localization.saveLocation,
      onPressed: isUpdating || isSaved ? null : onSave,
      icon: Icon(isSaved ? AppIcons.selected : AppIcons.save),
    ),
  );
}

class _SavedLocationTile extends StatelessWidget {
  const _SavedLocationTile({
    required this.location,
    required this.localization,
    required this.isActive,
    required this.isUpdating,
    required this.onSelect,
    required this.onRemove,
  });

  final SavedLocation location;
  final AppLocalizations localization;
  final bool isActive;
  final bool isUpdating;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(isActive ? AppIcons.selected : AppIcons.location),
    title: Text(location.city),
    subtitle: Text(
      [
        if (location.region.isNotEmpty) location.region,
        if (location.country.isNotEmpty) location.country,
        if (location.country.isEmpty && location.region.isEmpty)
          localization.savedLocations,
      ].join(', '),
    ),
    onTap: isUpdating ? null : onSelect,
    trailing: IconButton(
      tooltip: localization.removeLocation,
      onPressed: isUpdating ? null : onRemove,
      icon: const Icon(AppIcons.remove),
    ),
  );
}

class _LocationIssueCard extends StatelessWidget {
  const _LocationIssueCard({
    required this.issue,
    required this.localization,
    this.onOpenSettings,
  });

  final LocationIssue issue;
  final AppLocalizations localization;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.error, color: Theme.of(context).colorScheme.error),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_message, style: Theme.of(context).textTheme.bodyMedium),
              if (onOpenSettings != null) ...[
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: localization.openSettings,
                  variant: AppButtonVariant.secondary,
                  onPressed: onOpenSettings,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  String get _message => switch (issue) {
    LocationIssue.permissionDenied => localization.locationPermissionDenied,
    LocationIssue.permissionPermanentlyDenied =>
      localization.locationPermissionPermanentlyDenied,
    LocationIssue.serviceDisabled => localization.locationServicesDisabled,
    LocationIssue.currentLocationUnavailable =>
      localization.currentLocationUnavailable,
    LocationIssue.noSearchResults => localization.locationNoResults,
    LocationIssue.searchFailed => localization.locationSearchFailed,
    LocationIssue.storageFailure => localization.locationStorageFailed,
    LocationIssue.unknown => localization.locationUnknownError,
  };
}
