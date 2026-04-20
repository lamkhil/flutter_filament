import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../table_column.dart';

/// Truthy/falsy check-or-cross column. Filament: `IconColumn::make()->boolean()`.
class BooleanColumn<T> extends TableColumn<T> {
  final IconData trueIcon;
  final IconData falseIcon;

  BooleanColumn({
    required super.name,
    required super.label,
    super.align = ColumnAlign.center,
    super.width,
    super.accessor,
    this.trueIcon = Icons.check_circle,
    this.falseIcon = Icons.cancel,
  });

  @override
  Widget build(BuildContext context, T row) {
    final theme = FilamentThemeScope.of(context);
    final truthy = valueOf(row) == true;
    return Icon(
      truthy ? trueIcon : falseIcon,
      size: 18,
      color: truthy ? theme.colors.success : theme.colors.danger,
    );
  }
}
