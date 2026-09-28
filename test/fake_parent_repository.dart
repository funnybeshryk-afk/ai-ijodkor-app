import 'package:ai_ijodkor/data/models/parent_records.dart';
import 'package:ai_ijodkor/data/repositories/parent_repository.dart';

/// In-memory parent data; set [failOverview] to simulate a network error.
class FakeParentRepository implements ParentRepository {
  final children = <Child>[];
  final overviews = <String, ChildOverview>{};
  bool failOverview = false;
  int overviewCalls = 0;

  @override
  Future<List<Child>> fetchChildren(String parentId) async => children;

  @override
  Future<ChildOverview> fetchChildOverview(String childId) async {
    overviewCalls++;
    if (failOverview) throw Exception('offline');
    return overviews[childId]!;
  }
}
