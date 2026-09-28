import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import 'student_providers.dart';

/// The student's certificates; each links to the platform's public
/// verification page.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dates = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.certificatesTitle)),
      body: AsyncValueView(
        value: ref.watch(certificatesProvider),
        onRetry: () => ref.invalidate(certificatesProvider),
        builder: (items) => items.isEmpty
            ? MessageView(
                icon: Icons.workspace_premium_outlined,
                title: l10n.noCertificates,
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final cert in items)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  size: 40,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    cert.courseName,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(l10n.certificateNumber(cert.id)),
                            Text(
                              l10n.certificateIssued(
                                dates.formatMediumDate(cert.issuedAt.toLocal()),
                              ),
                            ),
                            if (cert.teacherName.isNotEmpty)
                              Text(l10n.certificateTeacher(cert.teacherName)),
                            if (Env.platformUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.open_in_new),
                                label: Text(l10n.certificateVerifyButton),
                                onPressed: () => launchUrl(
                                  Uri.parse(Env.platformUrl).resolve(
                                    '/certificate/verify/'
                                    '${Uri.encodeComponent(cert.id)}',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
