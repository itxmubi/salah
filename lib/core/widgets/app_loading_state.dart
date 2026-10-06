import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: label,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.md),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
