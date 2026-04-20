import 'package:flutter/widgets.dart';

/// How a column's value should be aligned in its cell.
enum ColumnAlign { start, center, end }

/// Base class for all table columns.
/// Filament equivalent: `Filament\Tables\Columns\Column`.
abstract class TableColumn<T> {
  final String name;
  final String label;
  final bool searchable;
  final bool sortable;
  final ColumnAlign align;
  final double? width;
  final dynamic Function(T row)? accessor;

  TableColumn({
    required this.name,
    required this.label,
    this.searchable = false,
    this.sortable = false,
    this.align = ColumnAlign.start,
    this.width,
    this.accessor,
  });

  /// Resolve the raw value for [row].
  dynamic valueOf(T row) => accessor?.call(row);

  /// Render the cell content.
  Widget build(BuildContext context, T row);
}
