import 'package:flutter/material.dart';
import '../table_column.dart';

/// Colored badge column. Filament: `TextColumn::make()->badge()`.
class BadgeColumn<T> extends TableColumn<T> {
  final Color Function(T row) color;
  final String Function(T row)? formatter;
  final IconData? Function(T row)? iconResolver;

  BadgeColumn({
    required super.name,
    required super.label,
    required this.color,
    super.searchable,
    super.sortable,
    super.align,
    super.width,
    super.accessor,
    this.formatter,
    this.iconResolver,
  });

  @override
  Widget build(BuildContext context, T row) {
    final c = color(row);
    final text = formatter?.call(row) ?? valueOf(row)?.toString() ?? '-';
    final icon = iconResolver?.call(row);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
