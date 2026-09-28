import '../../core/l10n.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value, AppLocalizations l10n) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return l10n.errorEmailRequired;
  if (!_emailPattern.hasMatch(email)) return l10n.errorEmailInvalid;
  return null;
}
