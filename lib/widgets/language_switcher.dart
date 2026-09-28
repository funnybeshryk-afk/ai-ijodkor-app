import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/locale_controller.dart';

/// uz / ru toggle; the choice is persisted by [LocaleController].
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(localeControllerProvider);
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 'uz', label: Text(l10n.languageUzbek)),
        ButtonSegment(value: 'ru', label: Text(l10n.languageRussian)),
      ],
      selected: {current.languageCode},
      onSelectionChanged: (selection) => ref
          .read(localeControllerProvider.notifier)
          .setLocale(Locale(selection.first)),
    );
  }
}
