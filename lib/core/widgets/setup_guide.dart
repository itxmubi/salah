import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/location/presentation/providers/location_controller.dart';
import '../../features/prayer/presentation/providers/prayer_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../settings/app_settings.dart';

class SetupGuide extends ConsumerStatefulWidget {
  const SetupGuide({this.onFinished, this.embedded = false, super.key});
  final bool embedded;
  final VoidCallback? onFinished;
  @override
  ConsumerState<SetupGuide> createState() => _SetupGuideState();
}

class _SetupGuideState extends ConsumerState<SetupGuide> {
  bool _reviewed = false;
  bool _saving = false;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final location = ref.watch(activeLocationProvider);
    final prayer = ref.watch(prayerControllerProvider).asData?.value;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          primary: !widget.embedded,
          physics: widget.embedded
              ? const NeverScrollableScrollPhysics()
              : null,
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              strings.setupTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(strings.setupDescription),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                location == null
                    ? Icons.location_on_outlined
                    : Icons.check_circle_outline,
              ),
              title: Text(strings.setupLocation),
              subtitle: location == null ? null : Text(location.city),
              onTap: () => context.push('/location'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: location != null && prayer != null,
              leading: Icon(
                _reviewed
                    ? Icons.check_circle_outline
                    : Icons.calculate_outlined,
              ),
              title: Text(strings.setupCalculation),
              onTap: location == null || prayer == null
                  ? null
                  : () async {
                      await context.push('/settings/calculation');
                      if (mounted) setState(() => _reviewed = true);
                    },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: location == null || !_reviewed || _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      try {
                        await ref
                            .read(appSettingsProvider.notifier)
                            .completeSetup();
                        if (mounted) widget.onFinished?.call();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.saveFailed)),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: Text(strings.finishSetup),
            ),
          ],
        ),
      ),
    );
  }
}
