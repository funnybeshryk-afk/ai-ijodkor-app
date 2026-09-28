import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Centered icon + title + text + optional actions, for empty/error states.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.s6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.messageMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSize.emptyBadge,
                height: AppSize.emptyBadge,
                decoration: BoxDecoration(
                  color: colors.brandTint,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: AppSize.iconEmpty,
                  color: colors.brandStrong,
                ),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(
                title,
                style: AppText.heading.copyWith(color: colors.ink),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpace.s2),
                Text(
                  message!,
                  style: AppText.body.copyWith(color: colors.inkSoft),
                  textAlign: TextAlign.center,
                ),
              ],
              for (final action in actions) ...[
                const SizedBox(height: AppSpace.s4),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
