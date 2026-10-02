/// Tashkent days (UTC+5, no daylight saving) and the streak of practice days.
/// Mirrors the platform's src/lib/review-schedule.ts (tashkentDayKey,
/// streakFromDayKeys); both are tested on the same cases.
const _tashkentOffset = Duration(hours: 5);

/// The Tashkent calendar day of a moment, as YYYY-MM-DD.
String tashkentDayKey(DateTime at) {
  final d = at.toUtc().add(_tashkentOffset);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}

/// Consecutive Tashkent days with at least one session, going back from today
/// or yesterday — either anchors the streak, so a student who hasn't practised
/// yet today doesn't see yesterday's streak zeroed; it breaks once a whole day
/// is skipped.
int streakFromDayKeys(Set<String> dayKeys, DateTime now) {
  String keyOf(int daysAgo) =>
      tashkentDayKey(now.subtract(Duration(days: daysAgo)));
  var offset = 0;
  if (!dayKeys.contains(keyOf(0))) {
    offset = 1;
    if (!dayKeys.contains(keyOf(1))) return 0;
  }
  var streak = 0;
  while (dayKeys.contains(keyOf(offset))) {
    streak += 1;
    offset += 1;
  }
  return streak;
}
