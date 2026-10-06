import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../features/location/presentation/providers/location_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/qibla_direction.dart';
import '../providers/qibla_providers.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final location = ref.watch(activeLocationProvider);
    if (location == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.qiblaTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppEmptyState(
              title: strings.qiblaTitle,
              description: strings.qiblaLocationRequired,
              actionLabel: strings.openLocation,
              onAction: () => context.push('/location'),
            ),
          ),
        ),
      );
    }

    final direction = QiblaDirection.fromCoordinates(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    final compass = ref.watch(compassHeadingProvider);
    final heading = compass.asData?.value;
    final relativeBearing = _normalize(
      direction.bearingDegrees - (heading ?? 0),
    );
    final colors = Theme.of(context).colorScheme;
    final dialSize = (MediaQuery.sizeOf(context).width - AppSpacing.md * 2)
        .clamp(180.0, 284.0)
        .toDouble();

    return Scaffold(
      appBar: AppBar(title: Text(strings.qiblaTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  location.city.isEmpty
                      ? strings.currentLocation
                      : location.city,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Semantics(
                    label: strings.qiblaBearing,
                    value:
                        '${direction.bearingDegrees.toStringAsFixed(0)} degrees',
                    child: ExcludeSemantics(
                      child: _CompassDial(
                        relativeBearing: relativeBearing,
                        headingDegrees: heading ?? 0,
                        size: dialSize,
                        color: colors.primary,
                        secondaryColor: colors.onSurfaceVariant,
                        northLabel: strings.compassNorth,
                        eastLabel: strings.compassEast,
                        southLabel: strings.compassSouth,
                        westLabel: strings.compassWest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  compass.when(
                    data: (value) => value == null
                        ? strings.compassUnavailable
                        : strings.compassAlignHint,
                    loading: () => strings.compassSearching,
                    error: (error, stackTrace) => strings.compassUnavailable,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _DirectionMetric(
                        label: strings.qiblaBearing,
                        value:
                            '${direction.bearingDegrees.toStringAsFixed(0)}°',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DirectionMetric(
                        label: strings.kaabaDistance,
                        value: '${direction.distanceKm.toStringAsFixed(0)} km',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.compassCalibrationTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              strings.compassCalibrationDescription,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double _normalize(double degrees) => (degrees % 360 + 360) % 360;
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.relativeBearing,
    required this.headingDegrees,
    required this.size,
    required this.color,
    required this.secondaryColor,
    required this.northLabel,
    required this.eastLabel,
    required this.southLabel,
    required this.westLabel,
  });

  final double relativeBearing;
  final double headingDegrees;
  final double size;
  final Color color;
  final Color secondaryColor;
  final String northLabel;
  final String eastLabel;
  final String southLabel;
  final String westLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -headingDegrees * math.pi / 180,
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Text(
                          northLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Text(
                          southLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            eastLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            westLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedRotation(
                turns: relativeBearing / 360,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Icon(Icons.navigation_rounded, size: 104, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionMetric extends StatelessWidget {
  const _DirectionMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}
