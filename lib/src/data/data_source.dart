import 'package:flutter/foundation.dart';

import 'paginated_result.dart';

/// Abstract data source for a [Resource]. Implement to back a resource
/// with Firestore, REST, GraphQL, or any persistence layer.
///
/// Filament equivalent: Eloquent model + its query builder.
abstract class DataSource<T> {
  final ValueNotifier<int> _changeTicker = ValueNotifier(0);

  /// Listenable yang fire setiap kali data berubah lewat data source ini
  /// (`create` / `update` / `delete`). Dipakai oleh `TableBuilderWidget`
  /// untuk re-fetch otomatis setelah mutasi — termasuk ketika edit page
  /// kembali ke list lewat `context.go(...)` (GoRouter mempertahankan
  /// instance list page sehingga `initState` tidak terpicu lagi).
  ///
  /// Concrete subclass wajib memanggil [notifyChanged] setelah mutasi
  /// untuk men-trigger refresh. `MemoryDataSource` sudah melakukannya;
  /// custom implementation perlu menambahkan sendiri.
  Listenable get onChange => _changeTicker;

  /// Bump ticker → semua listener `onChange` dipanggil.
  @protected
  void notifyChanged() => _changeTicker.value++;

  Future<PaginatedResult<T>> list(ListQuery query);

  Future<T?> get(String id);

  Future<T> create(Map<String, dynamic> data);

  Future<T> update(String id, Map<String, dynamic> data);

  Future<void> delete(String id);

  /// Optional live stream (e.g. Firestore `snapshots()`). Return `null` if
  /// not supported — the UI will fall back to one-shot `list`.
  Stream<List<T>>? watch(ListQuery query) => null;
}
