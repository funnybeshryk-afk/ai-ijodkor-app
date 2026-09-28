import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../data/providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import 'student_providers.dart';
import 'student_shell.dart';

/// This week's class leaderboard (get_class_leaderboard RPC).
class RatingScreen extends ConsumerWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final me = ref.watch(currentUserIdProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ratingTitle),
        actions: const [ProfileAction()],
      ),
      body: AsyncValueView(
        value: ref.watch(leaderboardProvider),
        onRetry: () => ref.invalidate(leaderboardProvider),
        builder: (entries) => RefreshIndicator(
          onRefresh: () => ref.refresh(leaderboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.ratingSubtitle, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                MessageView(
                  icon: Icons.emoji_events_outlined,
                  title: l10n.ratingEmpty,
                ),
              for (final (i, entry) in entries.indexed)
                Card(
                  key: entry.studentId == me ? const Key('rating_me') : null,
                  color: entry.studentId == me
                      ? theme.colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: _Place(place: i + 1),
                    title: Text(
                      entry.studentId == me
                          ? '${entry.fullName} (${l10n.ratingYou})'
                          : entry.fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Text(
                      l10n.ratingScore(entry.totalScore),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Place extends StatelessWidget {
  const _Place({required this.place});

  final int place;

  @override
  Widget build(BuildContext context) {
    const medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    final medal = medals[place];
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          medal ?? '$place',
          style: TextStyle(
            fontSize: medal == null ? 18 : 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
