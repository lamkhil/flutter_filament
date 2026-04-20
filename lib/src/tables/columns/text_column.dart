import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../table_column.dart';

/// Plain text column. Filament: `TextColumn::make('name')`.
class TextColumn<T> extends TableColumn<T> {
  final String Function(T row)? formatter;
  final bool bold;
  final int? maxLines;

  TextColumn({
    required super.name,
    required super.label,
    super.searchable,
    super.sortable,
    super.align,
    super.width,
    super.accessor,
    this.formatter,
    this.bold = false,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context, T row) {
    final theme = FilamentThemeScope.of(context);
    final text = formatter?.call(row) ?? valueOf(row)?.toString() ?? '-';
    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        color: theme.textPrimary,
      ),
    );
  }
}
