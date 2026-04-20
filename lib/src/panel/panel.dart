import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/navigation_group.dart';
import '../navigation/navigation_item.dart';
import '../pages/filament_page.dart';
import '../resource/resource.dart';
import '../tenant/tenant_access.dart';
import '../tenant/tenant_config.dart';
import '../tenant/tenant_scope.dart';
import '../theme/filament_theme.dart';
import '../widgets/dashboard_widget.dart';
import '../layout/dashboard_page.dart';
import 'panel_provider.dart';

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

  /// Konfigurasi multi-tenancy. `null` = panel single-tenant (mode lama).
  final TenantConfig? tenant;

  /// Implementasi yang memberitahu izin tenant user yang sedang login.
  /// Wajib diisi kalau [tenant] diisi.
  final TenantAccess? tenantAccess;

  /// Shared [TenantScope] — dibuat sekali per Panel, diresolusi dari URL
  /// oleh setiap page wrapper.
  late final TenantScope tenantScope = TenantScope();

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
    this.tenant,
    this.tenantAccess,
  }) : assert(tenant == null || tenantAccess != null,
            'tenantAccess wajib diisi kalau tenant dikonfigurasi');

  bool get isMultiTenant => tenant != null;

  /// Base path dengan tenant id kalau panel multi-tenant.
  /// `tenantId` diambil dari [TenantScope] / caller saat render.
  String basePath([String? tenantId]) {
    if (!isMultiTenant || tenantId == null) return path;
    return '$path/$tenantId';
  }

  /// Path lengkap untuk slug resource/page tertentu, aware tenant.
  /// - `unscoped=true` → `/admin/<slug>` (dipakai tenant resource sendiri).
  /// - `tenantId=null` di mode multi-tenant → `/admin/<slug>` (admin view,
  ///   bypass tenant). Non-admin tidak akan sampai sini berkat redirect.
  String routePath(String slug, {String? tenantId, bool unscoped = false}) {
    if (unscoped || !isMultiTenant || tenantId == null) return '$path/$slug';
    return '${basePath(tenantId)}/$slug';
  }

  /// Helper untuk navigasi antar page dalam satu resource.
  /// [subPath] opsional: `'create'`, `':id'`, atau `':id/edit'`.
  String resourcePath(
    String slug, {
    String? subPath,
    String? tenantId,
    bool unscoped = false,
  }) {
    final base = routePath(slug, tenantId: tenantId, unscoped: unscoped);
    return subPath == null ? base : '$base/$subPath';
  }

  /// Apakah slug ini adalah tenant resource sendiri (unscoped).
  bool isTenantResourceSlug(String slug) =>
      isMultiTenant && slug == tenant!.resource.slug && !tenant!.scopeSelf;

  /// Compute the sidebar model. [tenantId] dipakai untuk menyisipkan tenant
  /// di path setiap item supaya `context.go(item.path)` langsung valid.
  List<NavigationGroup> buildNavigation({String? tenantId}) {
    if (navigationOverride != null) return navigationOverride!;

    final dashboardGroup = NavigationGroup(
      items: [
        NavigationItem(
          label: dashboardTitle,
          icon: dashboardIcon,
          path: basePath(tenantId),
        ),
      ],
    );

    final grouped = <String?, List<NavigationItem>>{};
    for (final r in resources.where((r) => !r.hiddenFromNavigation)) {
      final isTenantResource =
          tenant != null && r.slug == tenant!.resource.slug;
      final unscoped = isTenantResource && !tenant!.scopeSelf;
      grouped.putIfAbsent(r.navigationGroup, () => []).add(
            NavigationItem(
              label: r.pluralLabel,
              icon: r.icon,
              path: routePath(r.slug,
                  tenantId: tenantId, unscoped: unscoped),
            ),
          );
    }
    for (final p in pages.where((p) => !p.hiddenFromNavigation)) {
      grouped.putIfAbsent(p.navigationGroup, () => []).add(
            NavigationItem(
              label: p.title,
              icon: p.icon,
              path: routePath(p.slug, tenantId: tenantId),
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
  ///
  /// Struktur:
  /// - Single-tenant: `/admin`, `/admin/<slug>`, `/admin/<slug>/create`, dst.
  /// - Multi-tenant: tenant resource tetap di `/admin/<tenantSlug>` (unscoped),
  ///   sementara resource lain + dashboard + pages pindah ke
  ///   `/admin/<tenantId>/...`. `/admin` di-redirect ke tenant pertama user.
  List<GoRoute> buildRoutes() {
    Widget wrap(Widget child, GoRouterState state) {
      final tenantId = isMultiTenant
          ? state.pathParameters['tenantId']
          : null;
      return _TenantBinder(
        scope: tenantScope,
        tenantId: tenantId,
        child: PanelProvider(panel: this, child: child),
      );
    }

    Page<dynamic> page(Widget child, GoRouterState state) =>
        NoTransitionPage(key: state.pageKey, child: wrap(child, state));

    final routes = <GoRoute>[];

    if (isMultiTenant) {
      // Dedup tenant resource: pakai instance di `resources` kalau ada.
      final tenantSlug = tenant!.resource.slug;
      final tenantResourceInList = resources.firstWhere(
        (r) => r.slug == tenantSlug,
        orElse: () => tenant!.resource,
      );

      // Root /admin:
      //   - admin global → langsung dashboard (tanpa tenant segment, data
      //     tidak ter-scope berkat TenantScope.adminBypass).
      //   - non-admin dengan akses → redirect ke /admin/{firstTenant}.
      //   - belum load / no access → stay, tampilkan loading/error screen.
      routes.add(GoRoute(
        path: path,
        redirect: (ctx, state) {
          final perms = tenantScope.permissions;
          if (perms.isGlobalAdmin) return null;
          if (perms.allowedIds.isNotEmpty) {
            return '$path/${perms.allowedIds.first}';
          }
          return null;
        },
        pageBuilder: (ctx, state) => NoTransitionPage(
          key: state.pageKey,
          child: wrap(_DashboardOrLoading(panel: this), state),
        ),
      ));

      // Tenant resource sendiri — unscoped, di /admin/<tenantSlug>/*
      routes.add(tenantResourceInList.buildRoute(path, panel: this));

      // Admin-mode (no tenant segment): resource lain + pages langsung
      // di /admin/<slug>. Admin bypass scope via TenantScope.adminBypass,
      // jadi data tidak ter-filter. Non-admin tidak akan sampai ke sini
      // berkat redirect di route root.
      for (final r in resources) {
        if (r.slug == tenantSlug) continue;
        routes.add(r.buildRoute(path, panel: this));
      }
      for (final p in pages) {
        routes.add(GoRoute(
          path: '$path/${p.slug}',
          pageBuilder: (ctx, state) => page(p, state),
        ));
      }

      // Tenant-mode (with :tenantId): scoped dashboard + resource + pages.
      final tenantBase = '$path/:tenantId';
      routes.add(GoRoute(
        path: tenantBase,
        pageBuilder: (ctx, state) => page(DashboardPage(panel: this), state),
      ));
      for (final r in resources) {
        if (r.slug == tenantSlug) continue;
        routes.add(r.buildRoute(tenantBase, panel: this));
      }
      for (final p in pages) {
        routes.add(GoRoute(
          path: '$tenantBase/${p.slug}',
          pageBuilder: (ctx, state) => page(p, state),
        ));
      }
    } else {
      // Single-tenant mode.
      routes.add(GoRoute(
        path: path,
        pageBuilder: (ctx, state) => page(DashboardPage(panel: this), state),
      ));
      for (final r in resources) {
        routes.add(r.buildRoute(path, panel: this));
      }
      for (final p in pages) {
        routes.add(GoRoute(
          path: '$path/${p.slug}',
          pageBuilder: (ctx, state) => page(p, state),
        ));
      }
    }

    return routes;
  }

  /// Initializer tenant scope — dipanggil dari main.dart setelah user login.
  /// Membaca [TenantAccess.permissions] lalu set state.
  Future<void> loadTenantPermissions() async {
    if (!isMultiTenant) return;
    tenantScope.markLoading();
    final perms = await tenantAccess!.permissions();
    tenantScope.setPermissions(perms);
  }
}

/// Widget internal yang memastikan [TenantScope.currentId] sinkron dengan
/// segment `:tenantId` di URL, lalu mengekspos scope ke subtree.
class _TenantBinder extends StatefulWidget {
  final TenantScope scope;
  final String? tenantId;
  final Widget child;

  const _TenantBinder({
    required this.scope,
    required this.tenantId,
    required this.child,
  });

  @override
  State<_TenantBinder> createState() => _TenantBinderState();
}

class _TenantBinderState extends State<_TenantBinder> {
  @override
  void initState() {
    super.initState();
    widget.scope.setCurrentId(widget.tenantId);
  }

  @override
  void didUpdateWidget(covariant _TenantBinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tenantId != widget.tenantId) {
      widget.scope.setCurrentId(widget.tenantId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TenantScopeProvider(notifier: widget.scope, child: widget.child);
  }
}

/// Di-render di route `/admin` (multi-tenant mode):
/// - Admin global → langsung tampilkan [DashboardPage].
/// - Permissions belum load → spinner.
/// - Non-admin tanpa akses → error state.
/// Non-admin dengan akses akan di-redirect sebelum widget ini di-render.
class _DashboardOrLoading extends StatelessWidget {
  final Panel panel;
  const _DashboardOrLoading({required this.panel});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: panel.tenantScope,
      builder: (ctx, _) {
        final scope = panel.tenantScope;
        final theme = panel.theme;
        final loaded = !scope.loading;

        // Admin global → langsung dashboard dengan akses penuh.
        if (loaded && scope.permissions.isGlobalAdmin) {
          return DashboardPage(panel: panel);
        }

        final noAccess = loaded &&
            !scope.permissions.isGlobalAdmin &&
            scope.permissions.allowedIds.isEmpty;

        return Scaffold(
          backgroundColor: theme.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (noAccess) ...[
                  Icon(Icons.lock_outline,
                      size: 48, color: theme.colors.danger),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada ${panel.tenant!.resource.label.toLowerCase()} '
                    'yang bisa diakses',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hubungi administrator untuk diberikan akses.',
                    style:
                        TextStyle(color: theme.textSecondary, fontSize: 13),
                  ),
                ] else ...[
                  CircularProgressIndicator(color: theme.colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data akses...',
                    style:
                        TextStyle(color: theme.textSecondary, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
