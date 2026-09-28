import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import 'brand_mark.dart';

/// Logo badge with the program name under it (login, splash).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoBadge(size: size, semanticLabel: context.l10n.logoLabel),
        const SizedBox(height: AppSpace.s3),
        Text(
          context.l10n.appTitle,
          style: AppText.displayLg.copyWith(
            color: context.colors.ink,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
