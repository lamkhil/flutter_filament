import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/navigation_group.dart';
import '../navigation/navigation_item.dart';
import '../panel/panel.dart';
import '../panel/panel_provider.dart';
import '../tenant/tenant_scope.dart';
import '../tenant/tenant_switcher.dart';
import '../theme/filament_theme.dart';

/// Mobile-threshold width.
const double _kMobileBreakpoint = 900;

/// The full admin shell: sidebar (or drawer on mobile) + topbar + content.
/// Filament equivalent: the default panel layout.
class PanelLayout extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> headerActions;
  final Widget child;

  /// When used standalone (i.e. not wrapped by a Panel-built route), callers
  /// can supply the panel explicitly. Otherwise, [PanelProvider.of] is used.
  final Panel? panelOverride;

  const PanelLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.headerActions = const [],
    this.panelOverride,
  });

  @override
  State<PanelLayout> createState() => _PanelLayoutState();
}

class _PanelLayoutState extends State<PanelLayout> {
  bool _sidebarCollapsed = false;

  Panel _resolvePanel(BuildContext context) =>
      widget.panelOverride ?? PanelProvider.of(context);

  @override
  Widget build(BuildContext context) {
    final panel = _resolvePanel(context);
    final theme = panel.theme;
    return FilamentThemeScope(
      theme: theme,
      child: PanelProvider(
        panel: panel,
        child: Builder(builder: (ctx) {
          final isMobile = MediaQuery.of(ctx).size.width < _kMobileBreakpoint;
          return Scaffold(
            backgroundColor: theme.background,
            drawer: isMobile ? _Sidebar(panel: panel) : null,
            body: Row(
              children: [
                if (!isMobile)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _sidebarCollapsed ? 72 : 260,
                    child: _Sidebar(
                      panel: panel,
                      collapsed: _sidebarCollapsed,
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        actions: widget.headerActions,
                        onToggleSidebar: () {
                          if (isMobile) {
                            Scaffold.of(ctx).openDrawer();
                          } else {
                            setState(
                                () => _sidebarCollapsed = !_sidebarCollapsed);
                          }
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback onToggleSidebar;

  const _TopBar({
    required this.title,
    required this.actions,
    required this.onToggleSidebar,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggleSidebar,
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const TenantSwitcher(),
          if (actions.isNotEmpty) const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final Panel panel;
  final bool collapsed;

  const _Sidebar({required this.panel, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final tenantId = TenantScopeProvider.maybeOf(context)?.currentId;
    final groups = panel.buildNavigation(tenantId: tenantId);
    final currentRoute = GoRouterState.of(context).uri.toString();
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(right: BorderSide(color: theme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Brand(panel: panel, collapsed: collapsed),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final group in groups)
                  _NavGroupView(
                    group: group,
                    collapsed: collapsed,
                    currentRoute: currentRoute,
                    panelPath: panel.path,
                  ),
              ],
            ),
          ),
          if (panel.sidebarFooter != null) ...[
            const Divider(height: 1),
            panel.sidebarFooter!,
          ],
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final Panel panel;
  final bool collapsed;
  const _Brand({required this.panel, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          if (panel.brandLogo != null)
            panel.brandLogo!
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  panel.brandName.isNotEmpty
                      ? panel.brandName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                panel.brandName,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavGroupView extends StatelessWidget {
  final NavigationGroup group;
  final bool collapsed;
  final String currentRoute;
  final String panelPath;

  const _NavGroupView({
    required this.group,
    required this.collapsed,
    required this.currentRoute,
    required this.panelPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.label != null && !collapsed)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Text(
              group.label!.toUpperCase(),
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        for (final item in group.items)
          _NavItemView(
            item: item,
            collapsed: collapsed,
            active: _isActive(item, currentRoute, panelPath),
          ),
      ],
    );
  }

  bool _isActive(NavigationItem item, String current, String panelPath) {
    if (item.path == panelPath) {
      return current == panelPath || current == '$panelPath/';
    }
    return current.startsWith(item.path);
  }
}

class _NavItemView extends StatelessWidget {
  final NavigationItem item;
  final bool collapsed;
  final bool active;

  const _NavItemView({
    required this.item,
    required this.collapsed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final bg = active ? theme.colors.primary.withValues(alpha: 0.12) : null;
    final fg = active ? theme.colors.primary : theme.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        onTap: () => context.go(item.path),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: fg),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: fg,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.badgeColor ?? theme.colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
