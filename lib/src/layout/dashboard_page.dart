import 'package:flutter/material.dart';
import '../panel/panel.dart';
import '../theme/filament_theme.dart';
import '../widgets/dashboard_widget.dart';
import 'panel_layout.dart';

/// Home page of a Panel. Renders the Panel's dashboard [widgets] in a
/// 12-column responsive grid driven by each widget's `columnSpan`.
class DashboardPage extends StatelessWidget {
  final Panel panel;
  const DashboardPage({super.key, required this.panel});

  @override
  Widget build(BuildContext context) {
    final widgets = [...panel.widgets]..sort((a, b) => a.sort.compareTo(b.sort));
    return PanelLayout(
      panelOverride: panel,
      title: panel.dashboardTitle,
      subtitle: 'Selamat datang di ${panel.brandName}',
      child: LayoutBuilder(
        builder: (ctx, c) {
          final isMobile = c.maxWidth < 600;
          final cellW = c.maxWidth / 12;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final w in widgets)
                SizedBox(
                  width: isMobile
                      ? c.maxWidth
                      : (cellW * _span(w) - 16).clamp(200.0, c.maxWidth),
                  child: w,
                ),
              if (widgets.isEmpty) _EmptyDashboard(),
            ],
          );
        },
      ),
    );
  }

  int _span(DashboardWidget w) => w.columnSpan.clamp(1, 12);
}

class _EmptyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dashboard_outlined,
              size: 48, color: theme.textMuted),
          const SizedBox(height: 8),
          Text(
            'Belum ada widget di dashboard',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
