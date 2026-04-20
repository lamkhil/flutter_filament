import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// The four built-in pages a Filament resource can expose.
enum DefaultPageKind { list, create, edit, view }

/// Declares a page (built-in or custom) belonging to a resource.
/// Filament: `Resource::getPages()` returns an array of these.
class ResourcePageDef {
  /// Slug appended to the resource's path (e.g. `''`, `'create'`, `':id/edit'`).
  final String path;

  /// Unique name within the resource (used in route names).
  final String name;

  /// One of the four default kinds, or null for a custom page.
  final DefaultPageKind? kind;

  /// Builder for custom pages. Ignored when [kind] is set.
  final Widget Function(BuildContext context, GoRouterState state)? builder;

  const ResourcePageDef({
    required this.path,
    required this.name,
    this.kind,
    this.builder,
  });

  /// List page — `/<resource>`.
  factory ResourcePageDef.list() => const ResourcePageDef(
        path: '',
        name: 'list',
        kind: DefaultPageKind.list,
      );

  /// Create page — `/<resource>/create`.
  factory ResourcePageDef.create() => const ResourcePageDef(
        path: 'create',
        name: 'create',
        kind: DefaultPageKind.create,
      );

  /// Edit page — `/<resource>/:id/edit`.
  factory ResourcePageDef.edit() => const ResourcePageDef(
        path: ':id/edit',
        name: 'edit',
        kind: DefaultPageKind.edit,
      );

  /// View page — `/<resource>/:id`.
  factory ResourcePageDef.view() => const ResourcePageDef(
        path: ':id',
        name: 'view',
        kind: DefaultPageKind.view,
      );

  /// Custom page with a full widget builder.
  factory ResourcePageDef.custom({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) =>
      ResourcePageDef(path: path, name: name, builder: builder);
}
