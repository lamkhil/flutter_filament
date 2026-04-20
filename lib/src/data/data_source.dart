import 'paginated_result.dart';

/// Abstract data source for a [Resource]. Implement to back a resource
/// with Firestore, REST, GraphQL, or any persistence layer.
///
/// Filament equivalent: Eloquent model + its query builder.
abstract class DataSource<T> {
  Future<PaginatedResult<T>> list(ListQuery query);

  Future<T?> get(String id);

  Future<T> create(Map<String, dynamic> data);

  Future<T> update(String id, Map<String, dynamic> data);

  Future<void> delete(String id);

  /// Optional live stream (e.g. Firestore `snapshots()`). Return `null` if
  /// not supported — the UI will fall back to one-shot `list`.
  Stream<List<T>>? watch(ListQuery query) => null;
}
