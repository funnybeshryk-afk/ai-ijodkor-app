import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import 'message_view.dart';

/// Loading spinner / error with retry / data, for a provider's AsyncValue.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => MessageView(
        icon: Icons.cloud_off_outlined,
        title: context.l10n.errorGeneric,
        actions: [
          FilledButton(
            onPressed: onRetry,
            child: Text(context.l10n.retryButton),
          ),
        ],
      ),
    );
  }
}
