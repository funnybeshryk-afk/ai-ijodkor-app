import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/providers.dart';

/// Signs out; the router then redirects to the login screen.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: const Icon(LucideIcons.logOut, size: AppSize.iconBtn),
      label: Text(context.l10n.signOutButton),
      onPressed: () => ref.read(authRepositoryProvider)?.signOut(),
    );
  }
}
