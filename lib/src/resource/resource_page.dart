import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'resource.dart';

/// One of the four built-in resource pages.
enum ResourcePageKind { list, create, view, edit }

/// Declares a page (built-in or custom) belonging to a [Resource].
///
/// Filament: `Resource::getPages()` returns an associative array keyed by
/// page name. The framework wires each entry to a route under the resource's
/// slug (e.g. `users` → `/admin/users`, `users/create` → `/admin/users/create`).
class ResourcePage<T> {
  /// Slug appended to the resource's path. Use `''` for the index page.
  final String path;

  /// One of the four default kinds, or null for a custom page.
  final ResourcePageKind? kind;

  /// Builder for custom pages. Ignored when [kind] is set.
  final Widget Function(
    BuildContext context,
    GoRouterState state,
    Resource<T> resource,
  )? builder;

  const ResourcePage({
    required this.path,
    this.kind,
    this.builder,
  }) : assert(kind != null || builder != null,
            'ResourcePage needs either a [kind] or a [builder]');

  bool get isDefault => kind != null;

  /// List page entry. Default mount: `/`. Pass [builder] to register a
  /// custom page widget while keeping list-page semantics (e.g. so the
  /// "Create" header action still wires up).
  ///
  /// Filament: `'index' => Pages\ListUsers::route('/')`.
  static ResourcePage<T> list<T>({
    String path = '',
    Widget Function(BuildContext, GoRouterState, Resource<T>)? builder,
  }) =>
      ResourcePage<T>(
          path: path, kind: ResourcePageKind.list, builder: builder);

  /// Create page entry. Default mount: `/create`.
  /// Filament: `'create' => Pages\CreateUser::route('/create')`.
  static ResourcePage<T> create<T>({
    String path = 'create',
    Widget Function(BuildContext, GoRouterState, Resource<T>)? builder,
  }) =>
      ResourcePage<T>(
          path: path, kind: ResourcePageKind.create, builder: builder);

  /// View page entry. Default mount: `/:id`.
  /// Filament: `'view' => Pages\ViewUser::route('/{record}')`.
  static ResourcePage<T> view<T>({
    String path = ':id',
    Widget Function(BuildContext, GoRouterState, Resource<T>)? builder,
  }) =>
      ResourcePage<T>(
          path: path, kind: ResourcePageKind.view, builder: builder);

  /// Edit page entry. Default mount: `/:id/edit`.
  /// Filament: `'edit' => Pages\EditUser::route('/{record}/edit')`.
  static ResourcePage<T> edit<T>({
    String path = ':id/edit',
    Widget Function(BuildContext, GoRouterState, Resource<T>)? builder,
  }) =>
      ResourcePage<T>(
          path: path, kind: ResourcePageKind.edit, builder: builder);

  /// Custom page mounted at [path] under the resource. The builder receives
  /// the owning [Resource] so it can call `resource.dataSource`, navigate to
  /// other pages, etc.
  static ResourcePage<T> custom<T>({
    required String path,
    required Widget Function(
      BuildContext,
      GoRouterState,
      Resource<T>,
    ) builder,
  }) =>
      ResourcePage<T>(path: path, builder: builder);
}
