import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../widgets/message_view.dart';

/// Shown when the app was built without Supabase `--dart-define` keys.
class ConfigMissingScreen extends StatelessWidget {
  const ConfigMissingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: MessageView(
        icon: LucideIcons.settings,
        title: l10n.configMissingTitle,
        message: l10n.configMissingBody,
      ),
    );
  }
}
