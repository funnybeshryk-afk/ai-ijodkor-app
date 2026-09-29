import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

export '../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Whether lesson content should use its Russian translation (the
  /// `*_ru` columns, platform migration 0020) where one exists.
  bool get contentRu => Localizations.localeOf(this).languageCode == 'ru';
}
