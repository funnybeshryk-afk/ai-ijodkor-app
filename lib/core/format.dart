import 'package:flutter/material.dart';

import 'l10n.dart';

/// "150000" -> "150 000" (narrow no-break spaces between thousands).
String formatAmount(num value) {
  final digits = value.round().abs().toString();
  final buf = StringBuffer(value < 0 ? '−' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// "150 000 so'm" in the current language.
String formatMoney(BuildContext context, num value) =>
    context.l10n.moneySum(formatAmount(value));

/// Month name for 1..12, with the year when it is not [now]'s year.
String formatPeriod(
  BuildContext context,
  int year,
  int month, {
  DateTime? now,
}) {
  final l10n = context.l10n;
  final name = l10n.monthName('m$month');
  return year == (now ?? DateTime.now()).year
      ? name
      : l10n.monthYear(name, year);
}

/// "Bugun, 14:20" / "Kecha, 17:05" / "12 sen. 2026".
String formatEventTime(BuildContext context, DateTime at, {DateTime? now}) {
  final l10n = context.l10n;
  final m = MaterialLocalizations.of(context);
  final local = at.toLocal();
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final day = DateUtils.dateOnly(local);
  final time = m.formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: true,
  );
  if (day == today) return l10n.whenToday(time);
  if (day == today.subtract(const Duration(days: 1))) {
    return l10n.whenYesterday(time);
  }
  return m.formatMediumDate(local);
}
