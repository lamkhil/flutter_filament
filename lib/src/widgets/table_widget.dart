import 'package:flutter/material.dart';
import '../data/data_source.dart';
import '../tables/table_builder_widget.dart';
import '../tables/table_schema.dart';
import '../theme/filament_theme.dart';
import 'dashboard_widget.dart';

/// Dashboard widget wrapping a [TableBuilderWidget] in a card.
/// Filament: `TableWidget`.
class TableDashboardWidget<T> extends DashboardWidget {
  final String title;
  final String? subtitle;
  final TableSchema<T> schema;
  final DataSource<T> dataSource;
  final String Function(T row) idOf;
  @override
  final int columnSpan;

  const TableDashboardWidget({
    super.key,
    required this.title,
    required this.schema,
    required this.dataSource,
    required this.idOf,
    this.subtitle,
    this.columnSpan = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textPrimary,
          ),
        ),
        if (subtitle != null)
          Text(subtitle!,
              style: TextStyle(color: theme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        TableBuilderWidget<T>(
          schema: schema,
          dataSource: dataSource,
          idOf: idOf,
        ),
      ],
    );
  }
}
