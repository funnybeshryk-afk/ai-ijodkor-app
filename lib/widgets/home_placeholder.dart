import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n.dart';
import '../core/routes.dart';
import 'message_view.dart';

/// Stub home screen for a role until its stage is implemented.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.profileTitle,
            iconSize: 32,
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push(Routes.profile),
          ),
        ],
      ),
      body: MessageView(icon: icon, title: title, message: l10n.comingSoon),
    );
  }
}
