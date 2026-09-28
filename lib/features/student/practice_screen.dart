import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../widgets/message_view.dart';
import 'student_shell.dart';
import 'trainers.dart';

/// Trainer hub; each trainer opens the platform page in a WebView.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.practiceTitle),
        actions: const [ProfileAction()],
      ),
      body: Env.platformUrl.isEmpty
          ? MessageView(
              icon: Icons.settings_suggest_outlined,
              title: l10n.platformNotConfigured,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.practiceSubtitle, style: theme.textTheme.bodyLarge),
                for (final track in trainerTracks) ...[
                  const SizedBox(height: 20),
                  Text(track.title(l10n), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.3,
                    children: [
                      for (final trainer in track.trainers)
                        _TrainerCard(trainer: trainer),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer});

  final Trainer trainer;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.trainer(trainer.key)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(trainer.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                trainer.title(context.l10n),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
