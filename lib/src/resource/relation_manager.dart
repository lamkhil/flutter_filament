import 'package:flutter/widgets.dart';

import '../data/data_source.dart';
import '../tables/table_schema.dart';

/// Embedded list of records related to a parent resource record.
/// Rendered as a tab section on the parent's edit/view pages.
///
/// Filament: `App\Filament\Resources\UserResource\RelationManagers\PostsRelationManager`.
///
/// Type parameters:
///   - [TParent] — the owning record type (e.g. `User`).
///   - [TChild]  — the related record type (e.g. `Post`).
abstract class RelationManager<TParent, TChild> {
  /// Tab label shown on the parent's edit/view page.
  String get title;

  /// Optional tab icon.
  IconData? get icon => null;

  /// Build the table schema scoped to [parent]. Columns and actions are
  /// the same shape as a regular `Resource.table()`.
  TableSchema<TChild> table(TParent parent);

  /// Returns a data source filtered to children of [parent].
  DataSource<TChild> dataSource(TParent parent);

  /// Extract the id from a child record (used as row key).
  String childId(TChild record);

  /// Optional hint shown above the table.
  String? get description => null;
}
