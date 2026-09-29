import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson.dart';
import '../models/parent_records.dart';
import '../models/student_records.dart';

/// Reads for the parent screen. Everything runs under the parent's session:
/// RLS (parent_child_links based policies, 0001/0002/0009) limits each
/// query to the parent's own children.
abstract class ParentRepository {
  Future<List<Child>> fetchChildren(String parentId);

  Future<ChildOverview> fetchChildOverview(String childId);
}

class SupabaseParentRepository implements ParentRepository {
  SupabaseParentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Child>> fetchChildren(String parentId) async {
    final links = await _client
        .from('parent_child_links')
        .select('student_id')
        .eq('parent_id', parentId);
    final ids = [for (final l in links) l['student_id'] as String];
    if (ids.isEmpty) return const [];
    final rows = await _client
        .from('profiles')
        .select('id, full_name')
        .inFilter('id', ids)
        .order('full_name');
    return [
      for (final r in rows)
        Child(
          id: r['id'] as String,
          fullName: (r['full_name'] as String?) ?? '',
        ),
    ];
  }

  @override
  Future<ChildOverview> fetchChildOverview(String childId) async {
    final results = await Future.wait([
      _client
          .from('lessons')
          .select(
            // `*` rather than a column list: picks up the *_ru translations
            // (migration 0020) once applied without failing before that.
            '*, lesson_access!inner(student_id)',
          )
          .eq('lesson_access.student_id', childId)
          .order('order_index'),
      _client
          .from('lesson_progress')
          .select('lesson_id, status, updated_at')
          .eq('student_id', childId),
      _client
          .from('homework_submissions')
          .select(
            'id, lesson_id, status, content_text, reviewer_notes, '
            'submitted_at, reviewed_at',
          )
          .eq('student_id', childId)
          .order('submitted_at', ascending: false),
      _client
          .from('points_ledger')
          .select('amount, reason, created_at')
          .eq('student_id', childId)
          .order('created_at', ascending: false),
      _client
          .from('payments')
          .select('id, period, amount, status, marked_at')
          .eq('student_id', childId)
          .order('period', ascending: false),
    ]);
    return ChildOverview(
      lessons: [for (final r in results[0]) Lesson.fromJson(r)],
      progress: [for (final r in results[1]) ProgressRow.fromJson(r)],
      homework: [for (final r in results[2]) HomeworkSubmission.fromJson(r)],
      points: [for (final r in results[3]) PointsEntry.fromJson(r)],
      payments: [for (final r in results[4]) Payment.fromJson(r)],
    );
  }
}
