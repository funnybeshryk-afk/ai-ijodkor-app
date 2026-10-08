import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/l10n.dart';
import '../features/offline/offline_game_screen.dart';
import '../data/xp.dart';
import '../core/theme.dart';
import 'message_view.dart';
import 'ui.dart';

/// Skeleton while loading / error with retry / data, for a provider's
/// AsyncValue.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
    this.loading,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  /// Screen-shaped skeleton; a generic list skeleton by default.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => loading ?? const SkeletonList(),
      error: (error, _) => error is DataUpdatingException
          ? DataUpdatingView(onRetry: onRetry)
          : ErrorRetryView(onRetry: onRetry),
    );
  }
}

/// «Something went wrong» with a retry button.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MessageView(
      icon: LucideIcons.wifiOff,
      title: l10n.errorGeneric,
      actions: [
        PrimaryButton(
          label: l10n.retryButton,
          icon: LucideIcons.refreshCw,
          onPressed: onRetry,
        ),
        const OfflineGameButton(),
      ],
    );
  }
}

/// Outlined «play while you wait» button under a connection error.
class OfflineGameButton extends StatelessWidget {
  const OfflineGameButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSize.button),
      ),
      icon: const Icon(LucideIcons.gamepad2, size: AppSize.iconBtn),
      label: Text(context.l10n.offlineGameButton),
      onPressed: () => OfflineGameScreen.open(context),
    );
  }
}

/// «Ma'lumot yangilanmoqda»: the database cannot answer yet (a newer platform
/// migration is not applied). Shown instead of numbers — never zeros.
class DataUpdatingView extends StatelessWidget {
  const DataUpdatingView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MessageView(
      icon: LucideIcons.refreshCw,
      title: l10n.dataUpdating,
      message: l10n.dataUpdatingHint,
      actions: [
        PrimaryButton(
          label: l10n.retryButton,
          icon: LucideIcons.refreshCw,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
