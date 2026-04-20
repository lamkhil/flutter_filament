import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/navigation_group.dart';
import '../navigation/navigation_item.dart';
import '../pages/filament_page.dart';
import '../resource/resource.dart';
import '../theme/filament_theme.dart';
import '../widgets/dashboard_widget.dart';
import '../layout/dashboard_page.dart';

/// Top-level container mirroring Filament 5's Panel concept.
/// A Panel groups resources, custom pages, widgets, theme and navigation.
class Panel {
  /// Unique panel id — useful when multiple panels coexist (`admin`, `app`).
  final String id;

  /// Mount path in the router (e.g. `/admin`).
  final String path;

  /// Brand shown in the top-left of the sidebar.
  final String brandName;
  final Widget? brandLogo;

  /// Theme (colors, typography).
  final FilamentTheme theme;

  /// Default dashboard page title.
  final String dashboardTitle;
  final IconData dashboardIcon;

  /// Resources exposed by this panel.
  final List<Resource> resources;

  /// Custom pages (non-resource).
  final List<FilamentPage> pages;

  /// Dashboard widgets shown on `path/` home.
  final List<DashboardWidget> widgets;

  /// Optional custom navigation layout. If null, auto-built from resources.
  final List<NavigationGroup>? navigationOverride;

  /// Custom sidebar footer (e.g. user dropdown).
  final Widget? sidebarFooter;

  Panel({
    required this.id,
    required this.path,
    required this.brandName,
    this.brandLogo,
    this.theme = const FilamentTheme(),
    this.dashboardTitle = 'Dashboard',
    this.dashboardIcon = Icons.dashboard_outlined,
    this.resources = const [],
    this.pages = const [],
    this.widgets = const [],
    this.navigationOverride,
    this.sidebarFooter,
  });

  /// Compute the sidebar model — auto-generated from resources + pages,
  /// unless `navigationOverride` is provided.
  List<NavigationGroup> buildNavigation() {
    if (navigationOverride != null) return navigationOverride!;

    final dashboardGroup = NavigationGroup(
      items: [
        NavigationItem(
          label: dashboardTitle,
          icon: dashboardIcon,
          path: path,
        ),
      ],
    );

    final grouped = <String?, List<NavigationItem>>{};
    for (final r in resources.where((r) => !r.hiddenFromNavigation)) {
      grouped.putIfAbsent(r.navigationGroup, () => []).add(
            NavigationItem(
              label: r.pluralLabel,
              icon: r.icon,
              path: '$path/${r.slug}',
            ),
          );
    }
    for (final p in pages.where((p) => !p.hiddenFromNavigation)) {
      grouped.putIfAbsent(p.navigationGroup, () => []).add(
            NavigationItem(
              label: p.title,
              icon: p.icon,
              path: '$path/${p.slug}',
            ),
          );
    }

    return [
      dashboardGroup,
      for (final entry in grouped.entries)
        NavigationGroup(label: entry.key, items: entry.value),
    ];
  }

  /// Returns the list of [GoRoute]s to register with GoRouter.
  List<GoRoute> buildRoutes() {
    return [
      GoRoute(
        path: path,
        name: '$id.dashboard',
        builder: (ctx, state) => DashboardPage(panel: this),
      ),
      for (final r in resources) r.buildRoute(path),
      for (final p in pages)
        GoRoute(
          path: '$path/${p.slug}',
          name: '$id.${p.slug}',
          builder: (ctx, state) => p,
        ),
    ];
  }
}
