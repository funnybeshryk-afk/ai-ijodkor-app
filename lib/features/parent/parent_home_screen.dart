import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../widgets/home_placeholder.dart';

/// Stage 3 will replace this stub.
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => HomePlaceholder(
    title: context.l10n.parentHomeTitle,
    icon: LucideIcons.users,
    message: context.l10n.parentSectionBody,
    platformPath: '/parent',
  );
}
