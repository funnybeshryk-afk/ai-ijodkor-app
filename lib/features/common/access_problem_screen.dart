import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth_gate.dart';
import '../../core/l10n.dart';
import '../../data/providers.dart';
import '../../widgets/message_view.dart';
import '../../widgets/sign_out_button.dart';

/// Signed in, but the profile could not be loaded, has no known role, or
/// belongs to an archived student.
class AccessProblemScreen extends ConsumerWidget {
  const AccessProblemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(authGateProvider).status;
    final isError = status == GateStatus.error;
    final isArchived = status == GateStatus.archived;
    return Scaffold(
      body: SafeArea(
        child: MessageView(
          icon: isError ? Icons.cloud_off_outlined : Icons.lock_outline,
          title: isError
              ? l10n.errorGeneric
              : isArchived
              ? l10n.archivedTitle
              : l10n.noAccessTitle,
          message: isError
              ? l10n.profileLoadError
              : isArchived
              ? l10n.archivedBody
              : l10n.noAccessBody,
          actions: [
            if (isError)
              FilledButton(
                onPressed: () => ref.invalidate(currentProfileProvider),
                child: Text(l10n.retryButton),
              ),
            const SignOutButton(),
          ],
        ),
      ),
    );
  }
}
