import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/filament_theme.dart';
import '../table_column.dart';

/// Formatted date column. Filament: `TextColumn::make('created_at')->date()`.
class DateColumn<T> extends TableColumn<T> {
  final String pattern;
  final String locale;

  DateColumn({
    required super.name,
    required super.label,
    super.searchable,
    super.sortable,
    super.align,
    super.width,
    super.accessor,
    this.pattern = 'dd MMM yyyy',
    this.locale = 'id_ID',
  });

  @override
  Widget build(BuildContext context, T row) {
    final theme = FilamentThemeScope.of(context);
    final value = valueOf(row);
    final dt = value is DateTime
        ? value
        : value is String
            ? DateTime.tryParse(value)
            : null;
    final text = dt != null ? DateFormat(pattern, locale).format(dt) : '-';
    return Text(text, style: TextStyle(color: theme.textPrimary));
  }
}
