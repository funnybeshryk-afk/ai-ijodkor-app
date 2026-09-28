import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../data/providers.dart';

/// Signs out; the router then redirects to the login screen.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout),
      label: Text(context.l10n.signOutButton),
      onPressed: () => ref.read(authRepositoryProvider)?.signOut(),
    );
  }
}
