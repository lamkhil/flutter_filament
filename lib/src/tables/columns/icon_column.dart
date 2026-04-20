import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../table_column.dart';

/// Row-driven icon column. Filament: `IconColumn::make('flag')`.
class IconColumn<T> extends TableColumn<T> {
  final IconData Function(T row) icon;
  final Color Function(T row)? color;
  final double size;

  IconColumn({
    required super.name,
    required super.label,
    required this.icon,
    super.align = ColumnAlign.center,
    super.width,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, T row) {
    final theme = FilamentThemeScope.of(context);
    return Icon(
      icon(row),
      size: size,
      color: color?.call(row) ?? theme.colors.primary,
    );
  }
}
