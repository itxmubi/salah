import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/generated/app_localizations.dart';

class JuzSelectionScreen extends StatelessWidget {
  const JuzSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.quranByJuz)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 30,
              itemBuilder: (context, index) {
                final juz = index + 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: AppCard(
                    padding: 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        child: Text('$juz'),
                      ),
                      title: Text(strings.quranJuzNumber(juz)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/quran/juz/$juz'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
