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
import 'relation_manager.dart';
import 'resource_context.dart';
import 'resource_page.dart';

/// A model-backed resource with list/create/edit/view pages.
///
/// Filament equivalent: `Filament\Resources\Resource`. Override the abstract
/// getters/methods to declare schema, table, relations, and pages — the
/// framework builds routes, navigation entries, and CRUD UI automatically.
abstract class Resource<T> {
  // ── Identity & navigation ────────────────────────────────────────────────

  /// Slug segment used in the URL (e.g. `'users'` → `/admin/users`).
  String get slug;

  /// Singular human label.
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

  // ── Data ─────────────────────────────────────────────────────────────────

  /// The data source (Firestore / REST / memory).
  DataSource<T> get dataSource;

  /// Extract the id from a record (used for route `:id`).
  String recordId(T record);

  /// Title shown on list rows, edit page header, breadcrumbs.
  String recordTitle(T record);

  /// Converts a fully-populated record into form values for the edit page.
  Map<String, dynamic> toFormData(T record);

  // ── Schema ───────────────────────────────────────────────────────────────

  /// Form schema — can branch by `ctx.operation`.
  FormSchema form(ResourceContext<T> ctx);

  /// Table schema for the list page.
  TableSchema<T> table();

  // ── Relations & pages ────────────────────────────────────────────────────

  /// Relation managers shown as tabs on edit/view pages.
  /// Filament: `Resource::getRelations()`.
  List<RelationManager> relations() => const [];

  /// Pages registered under this resource. Keys identify the page within
  /// the resource (e.g. `'index'`, `'create'`); values declare the route.
  /// Default: list/create/view/edit. Override to drop pages or add custom
  /// ones via [ResourcePage.custom].
  ///
  /// Filament: `Resource::getPages()`.
  Map<String, ResourcePage<T>> pages() => {
        'index': ResourcePage.list<T>(),
        'create': ResourcePage.create<T>(),
        'view': ResourcePage.view<T>(),
        'edit': ResourcePage.edit<T>(),
      };

  /// Hook: extra row actions beyond the defaults declared in [table].
  List<RowAction<T>> extraRowActions() => const [];

  // ── Internal route building ──────────────────────────────────────────────

  /// Build a tree of [GoRoute]s for this resource. Called by the Panel.
  ///
  /// All pages use [NoTransitionPage] — admin panel UX.
  GoRoute buildRoute(String panelPath, {Panel? panel}) {
    final base = '$panelPath/$slug';
    final pages = this.pages();
    Widget wrap(Widget child) =>
        panel == null ? child : PanelProvider(panel: panel, child: child);
    Page<dynamic> page(Widget child, GoRouterState state) =>
        NoTransitionPage(key: state.pageKey, child: wrap(child));

    final indexEntry = pages.entries.firstWhere(
      (e) => e.value.kind == ResourcePageKind.list || e.value.path.isEmpty,
      orElse: () =>
          MapEntry('index', ResourcePage<T>(path: '', kind: ResourcePageKind.list)),
    );

    return GoRoute(
      path: base,
      pageBuilder: (ctx, state) =>
          page(_build(ctx, state, indexEntry.value), state),
      routes: [
        for (final entry in pages.entries.where((e) => e.key != indexEntry.key))
          GoRoute(
            path: entry.value.path,
            pageBuilder: (ctx, state) =>
                page(_build(ctx, state, entry.value), state),
          ),
      ],
    );
  }

  Widget _build(BuildContext ctx, GoRouterState state, ResourcePage<T> page) {
    if (page.builder != null) return page.builder!(ctx, state, this);
    switch (page.kind) {
      case ResourcePageKind.list:
        return ListRecordsPage<T>(resource: this);
      case ResourcePageKind.create:
        return CreateRecordPage<T>(resource: this);
      case ResourcePageKind.edit:
        return EditRecordPage<T>(
          resource: this,
          recordId: state.pathParameters['id']!,
        );
      case ResourcePageKind.view:
        return ViewRecordPage<T>(
          resource: this,
          recordId: state.pathParameters['id']!,
        );
      case null:
        throw StateError('ResourcePage missing both kind and builder');
    }
  }

  /// Returns true if this resource has an edit page (default or custom).
  bool get hasEditPage =>
      pages().values.any((p) => p.kind == ResourcePageKind.edit);

  /// Returns true if this resource has a view page.
  bool get hasViewPage =>
      pages().values.any((p) => p.kind == ResourcePageKind.view);
}
