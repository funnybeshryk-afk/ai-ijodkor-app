import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/l10n.dart';
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
      error: (_, _) => ErrorRetryView(onRetry: onRetry),
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
      ],
    );
  }
}
