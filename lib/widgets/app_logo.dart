import 'package:flutter/material.dart';

import '../core/l10n.dart';

/// Brand logo (assets/branding/logo.png) with the app name under it.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/logo.png',
          height: size,
          semanticLabel: context.l10n.appTitle,
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
