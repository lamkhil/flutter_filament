import 'package:flutter/material.dart';
import '../theme/filament_theme.dart';
import 'dashboard_widget.dart';

/// One data point for the built-in simple bar chart.
class ChartPoint {
  final String label;
  final double value;
  const ChartPoint(this.label, this.value);
}

/// A lightweight built-in bar chart. For richer charts users can swap in
/// fl_chart by providing their own [DashboardWidget] subclass.
/// Filament: `ChartWidget`.
class ChartWidget extends DashboardWidget {
  final String title;
  final String? subtitle;
  final List<ChartPoint> data;
  final Color? color;
  @override
  final int columnSpan;

  const ChartWidget({
    super.key,
    required this.title,
    required this.data,
    this.subtitle,
    this.color,
    this.columnSpan = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final c = color ?? theme.colors.primary;
    final maxV = data.isEmpty
        ? 1.0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
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
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final p in data)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            p.value.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: (p.value / maxV) * 120,
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.75),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
