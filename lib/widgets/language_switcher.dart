import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';

/// uz / ru pill toggle (mockup «Kirish»); the choice is persisted by
/// [LocaleController].
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final current = ref.watch(localeControllerProvider).languageCode;

    Widget option(String code, String label) {
      final selected = current == code;
      return Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => ref
              .read(localeControllerProvider.notifier)
              .setLocale(Locale(code)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: AppSize.segmentHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.card),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.surfaceCard : null,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: selected ? Border.all(color: colors.border) : null,
            ),
            child: Text(
              label,
              style: AppText.label.copyWith(
                color: selected ? colors.ink : colors.inkMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: l10n.languageLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.s1),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            option('uz', l10n.languageUzbek),
            const SizedBox(width: AppSpace.s1),
            option('ru', l10n.languageRussian),
          ],
        ),
      ),
    );
  }
}
