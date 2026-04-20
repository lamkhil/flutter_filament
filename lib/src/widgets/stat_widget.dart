import 'package:flutter/material.dart';
import '../theme/filament_theme.dart';
import 'dashboard_widget.dart';

/// A single "stat" tile: label + big value + optional delta & icon.
/// Filament: `Stats\Stat::make('users', 1234)`.
class Stat {
  final String label;
  final String value;
  final String? description;
  final IconData? icon;
  final Color? color;
  final double? delta;

  const Stat({
    required this.label,
    required this.value,
    this.description,
    this.icon,
    this.color,
    this.delta,
  });
}

/// Dashboard widget rendering a row of [Stat]s.
/// Filament: `StatsOverviewWidget`.
class StatWidget extends DashboardWidget {
  final List<Stat> stats;
  @override
  final int columnSpan;

  const StatWidget({
    super.key,
    required this.stats,
    this.columnSpan = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final tileMin = 180.0;
        final perRow = (c.maxWidth / (tileMin + 12)).floor().clamp(1, stats.length);
        final tileW = (c.maxWidth - (perRow - 1) * 12) / perRow;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final s in stats)
              SizedBox(width: tileW, child: _StatTile(stat: s)),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final Stat stat;
  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final c = stat.color ?? theme.colors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (stat.icon != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(stat.icon, size: 14, color: c),
                ),
              if (stat.icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stat.label,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (stat.delta != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stat.delta! >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 12,
                      color: stat.delta! >= 0
                          ? theme.colors.success
                          : theme.colors.danger,
                    ),
                    Text(
                      '${stat.delta!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: stat.delta! >= 0
                            ? theme.colors.success
                            : theme.colors.danger,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          if (stat.description != null) ...[
            const SizedBox(height: 4),
            Text(
              stat.description!,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
