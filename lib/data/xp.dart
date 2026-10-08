import 'package:supabase_flutter/supabase_flutter.dart';

/// The database cannot answer a read that depends on a newer platform
/// migration (usually because it is not applied yet). Screens show
/// «Ma'lumot yangilanmoqda» instead of numbers — never zeros.
class DataUpdatingException implements Exception {
  const DataUpdatingException(this.source, [this.cause]);

  final String source;
  final Object? cause;

  @override
  String toString() => 'DataUpdatingException($source): $cause';
}

/// XP of the given students (platform migration 0040: the same score as the
/// rating, over all time; the database returns only the students the caller
/// may see). Throws [DataUpdatingException] if the function is not there.
Future<Map<String, int>> fetchXpOf(
  SupabaseClient client,
  List<String> studentIds,
) async {
  if (studentIds.isEmpty) return const {};
  try {
    final rows = await client.rpc<List<dynamic>>(
      'students_xp',
      params: {'p_student_ids': studentIds},
    );
    return {
      for (final row in rows)
        (row as Map)['student_id'] as String: (row['xp'] as num).toInt(),
    };
  } on PostgrestException catch (e) {
    throw DataUpdatingException('students_xp', e);
  }
}

/// [fetchXpOf] for one student; null when the database cannot answer yet
/// (the screen shows a placeholder, not 0).
Future<int?> fetchXpOrNull(SupabaseClient client, String studentId) async {
  try {
    return (await fetchXpOf(client, [studentId]))[studentId] ?? 0;
  } on DataUpdatingException {
    return null;
  }
}
