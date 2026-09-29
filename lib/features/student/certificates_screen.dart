import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';

/// The student's certificates; each links to the platform's public
/// verification page.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final dates = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backLabel,
          icon: const Icon(LucideIcons.chevronLeft, size: AppSize.iconLg),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.certificatesTitle),
      ),
      body: AsyncValueView(
        value: ref.watch(certificatesProvider),
        onRetry: () => ref.invalidate(certificatesProvider),
        builder: (items) => items.isEmpty
            ? MessageView(icon: LucideIcons.award, title: l10n.noCertificates)
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpace.s5),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s3),
                itemBuilder: (context, i) {
                  final cert = items[i];
                  final caption = AppText.caption.copyWith(
                    color: colors.inkSoft,
                  );
                  return Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const IconTile(icon: LucideIcons.award),
                            const SizedBox(width: AppSpace.s3),
                            Expanded(
                              child: Text(
                                cert.courseNameIn(ru: context.contentRu),
                                style: AppText.heading.copyWith(
                                  color: colors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.s3),
                        Text(
                          l10n.certificateNumber(cert.id),
                          style: AppText.code.copyWith(color: colors.ink),
                        ),
                        Text(
                          l10n.certificateIssued(
                            dates.formatMediumDate(cert.issuedAt.toLocal()),
                          ),
                          style: caption,
                        ),
                        if (cert.teacherName.isNotEmpty)
                          Text(
                            l10n.certificateTeacher(cert.teacherName),
                            style: caption,
                          ),
                        if (Env.platformUrl.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.s3),
                          OutlinedButton.icon(
                            icon: const Icon(
                              LucideIcons.externalLink,
                              size: AppSize.iconMd,
                            ),
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
                  );
                },
              ),
      ),
    );
  }
}
