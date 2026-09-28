import 'package:flutter/material.dart';

import '../core/l10n.dart';

/// Temporary logo until the brand assets are added.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: Icon(
            Icons.auto_awesome,
            size: size * 0.55,
            color: colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
