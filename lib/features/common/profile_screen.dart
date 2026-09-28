import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/sign_out_button.dart';

/// Shared profile screen for all roles: language and sign-out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.languageLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const LanguageSwitcher(),
          const SizedBox(height: 40),
          const SignOutButton(),
        ],
      ),
    );
  }
}
