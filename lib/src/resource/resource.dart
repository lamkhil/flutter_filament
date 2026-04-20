import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../actions/row_action.dart';
import '../data/data_source.dart';
import '../forms/form_schema.dart';
import '../pages/create_record_page.dart';
import '../pages/edit_record_page.dart';
import '../pages/list_records_page.dart';
import '../pages/view_record_page.dart';
import '../panel/panel.dart';
import '../panel/panel_provider.dart';
import '../tables/table_schema.dart';
import 'resource_context.dart';
import 'resource_page_def.dart';

/// A model-backed resource with list/create/edit/view pages.
/// Filament equivalent: `Filament\Resources\Resource`.
abstract class Resource<T> {
  /// Slug segment used in the URL (e.g. `'produk'` → `/admin/produk`).
  String get slug;

  /// Singular human label (Indonesian by default).
  String get label;

  /// Plural form shown on list page and navigation.
  String get pluralLabel => '${label}s';

  /// Material icon for the sidebar.
  IconData get icon;

  /// Optional sidebar group — e.g. `'Master Data'`.
  String? get navigationGroup => null;

  /// Sort order inside navigation group. Lower = earlier.
  int get navigationSort => 0;

  /// Should this resource appear in the sidebar? Default: yes.
  bool get hiddenFromNavigation => false;

  /// The data source (Firestore / REST / memory).
  DataSource<T> get dataSource;

  /// Extract the id from a record (used for route `:id`).
  String recordId(T record);

  /// Title shown on list rows, edit page header, breadcrumbs.
  String recordTitle(T record);

  /// Converts a fully-populated record into form values for the edit page.
  Map<String, dynamic> toFormData(T record);

  /// Form schema — can branch by `ctx.operation`.
  FormSchema form(ResourceContext<T> ctx);

  /// Table schema for the list page.
  TableSchema<T> table();

  /// Override to customise which pages exist. Default: list, create, edit, view.
  List<ResourcePageDef> pages() => [
        ResourcePageDef.list(),
        ResourcePageDef.create(),
        ResourcePageDef.edit(),
        ResourcePageDef.view(),
      ];

  /// Hook: extra row actions beyond the defaults. Implementations may merge
  /// these with the ones declared on [table]`.rowActions`.
  List<RowAction<T>> extraRowActions() => const [];

  /// Build a tree of [GoRoute]s for this resource. Called by the Panel.
  /// [panel] dipakai untuk wrap setiap page dengan [PanelProvider] supaya
  /// `PanelLayout.of(context)` berhasil di dalam list/create/edit/view.
  ///
  /// Semua page memakai [NoTransitionPage] — pindah halaman dalam panel
  /// tanpa animasi (mengikuti UX admin panel).
  GoRoute buildRoute(String panelPath, {Panel? panel}) {
    final base = '$panelPath/$slug';
    final pages = this.pages();
    Widget wrap(Widget child) =>
        panel == null ? child : PanelProvider(panel: panel, child: child);
    Page<dynamic> page(Widget child, GoRouterState state) =>
        NoTransitionPage(key: state.pageKey, child: wrap(child));

    // Tidak pakai `name:` — multi-tenant mode men-register route yang sama
    // dua kali (admin-flat + tenant-scoped) dan name harus unik di GoRouter.
    // Navigasi antar page pakai `context.go(panel.resourcePath(...))`.
    final list = pages.firstWhere(
      (p) => p.kind == DefaultPageKind.list,
      orElse: () => ResourcePageDef(path: '', name: 'list'),
    );
    return GoRoute(
      path: base,
      pageBuilder: (ctx, state) => page(_buildForKind(ctx, state, list), state),
      routes: [
        for (final p in pages.where((p) => p.kind != DefaultPageKind.list))
          GoRoute(
            path: p.path,
            pageBuilder: (ctx, state) =>
                page(_buildForKind(ctx, state, p), state),
          ),
      ],
    );
  }

  Widget _buildForKind(BuildContext ctx, GoRouterState state,
      ResourcePageDef page) {
    switch (page.kind) {
      case DefaultPageKind.list:
        return ListRecordsPage<T>(resource: this);
      case DefaultPageKind.create:
        return CreateRecordPage<T>(resource: this);
      case DefaultPageKind.edit:
        return EditRecordPage<T>(
          resource: this,
          recordId: state.pathParameters['id']!,
        );
      case DefaultPageKind.view:
        return ViewRecordPage<T>(
          resource: this,
          recordId: state.pathParameters['id']!,
        );
      case null:
        return page.builder!(ctx, state);
    }
  }
}
