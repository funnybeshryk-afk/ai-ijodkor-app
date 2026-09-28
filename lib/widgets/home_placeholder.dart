import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/env.dart';
import '../core/l10n.dart';
import '../core/routes.dart';
import 'message_view.dart';
import 'ui.dart';

/// Home of a role whose app screens are not built yet (parent: stage 3,
/// teacher: stage 4). Says so plainly and links to the web platform page
/// that does the job today.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    required this.platformPath,
  });

  final String title;
  final IconData icon;
  final String message;

  /// Page on the platform, e.g. `/parent`.
  final String platformPath;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.profileTitle,
            icon: const Icon(LucideIcons.user),
            onPressed: () => context.push(Routes.profile),
          ),
        ],
      ),
      body: MessageView(
        icon: icon,
        title: title,
        message: message,
        actions: [
          if (Env.platformUrl.isNotEmpty)
            PrimaryButton(
              label: l10n.openPlatformButton,
              trailingIcon: LucideIcons.externalLink,
              onPressed: () => launchUrl(
                Uri.parse(Env.platformUrl).resolve(platformPath),
                mode: LaunchMode.externalApplication,
              ),
            ),
        ],
      ),
    );
  }
}
