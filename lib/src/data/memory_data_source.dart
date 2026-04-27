import 'data_source.dart';
import 'paginated_result.dart';

/// In-memory [DataSource] useful for prototyping and tests.
class MemoryDataSource<T> extends DataSource<T> {
  final String Function(T) idOf;
  final Map<String, dynamic> Function(T) toMap;
  final T Function(Map<String, dynamic>) fromMap;
  final bool Function(T record, String query)? searchMatcher;

  final List<T> _store;
  int _seq = 0;

  MemoryDataSource({
    required this.idOf,
    required this.toMap,
    required this.fromMap,
    this.searchMatcher,
    List<T>? seed,
  }) : _store = [...?seed];

  @override
  Future<PaginatedResult<T>> list(ListQuery query) async {
    Iterable<T> rows = _store;
    if (query.search != null && query.search!.isNotEmpty) {
      final q = query.search!.toLowerCase();
      rows = rows.where((r) =>
          searchMatcher?.call(r, q) ??
          toMap(r).values.any((v) =>
              v != null && v.toString().toLowerCase().contains(q)));
    }
    for (final entry in query.filters.entries) {
      if (entry.value == null) continue;
      rows = rows.where((r) => toMap(r)[entry.key] == entry.value);
    }
    final list = rows.toList();
    if (query.sortBy != null) {
      list.sort((a, b) {
        final av = toMap(a)[query.sortBy];
        final bv = toMap(b)[query.sortBy];
        if (av == null && bv == null) return 0;
        if (av == null) return 1;
        if (bv == null) return -1;
        final cmp = Comparable.compare(av as Comparable, bv as Comparable);
        return query.sortDesc ? -cmp : cmp;
      });
    }
    final total = list.length;
    final start = (query.page - 1) * query.perPage;
    final end = (start + query.perPage).clamp(0, total);
    final page = start >= total ? <T>[] : list.sublist(start, end);
    return PaginatedResult(
      data: page,
      total: total,
      page: query.page,
      perPage: query.perPage,
    );
  }

  @override
  Future<T?> get(String id) async {
    for (final r in _store) {
      if (idOf(r) == id) return r;
    }
    return null;
  }

  @override
  Future<T> create(Map<String, dynamic> data) async {
    final withId = {...data, 'id': data['id'] ?? _nextId()};
    final record = fromMap(withId);
    _store.add(record);
    notifyChanged();
    return record;
  }

  @override
  Future<T> update(String id, Map<String, dynamic> data) async {
    final idx = _store.indexWhere((r) => idOf(r) == id);
    if (idx == -1) {
      throw StateError('Record $id not found');
    }
    final merged = {...toMap(_store[idx]), ...data, 'id': id};
    final updated = fromMap(merged);
    _store[idx] = updated;
    notifyChanged();
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _store.removeWhere((r) => idOf(r) == id);
    notifyChanged();
  }

  String _nextId() => 'mem_${++_seq}';
}
