import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../panel/panel_provider.dart';
import '../resource/resource.dart';
import '../resource/resource_page.dart';
import '../tables/table_builder_widget.dart';
import '../tenant/tenant_scope.dart';
import '../theme/filament_theme.dart';
import '../layout/panel_layout.dart';

/// The list page of a [Resource]. Renders the resource's [TableSchema] and
/// provides a header action to navigate to the create page (if declared).
class ListRecordsPage<T> extends StatelessWidget {
  final Resource<T> resource;
  const ListRecordsPage({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final panel = PanelProvider.of(context);
    final tenantId = TenantScopeProvider.maybeOf(context)?.currentId;
    final unscoped = panel.isTenantResourceSlug(resource.slug);
    final hasCreate = resource
        .pages()
        .values
        .any((p) => p.kind == ResourcePageKind.create);

    String pathFor(String? sub) => panel.resourcePath(
          resource.slug,
          subPath: sub,
          tenantId: tenantId,
          unscoped: unscoped,
        );

    return PanelLayout(
      title: resource.pluralLabel,
      subtitle: 'Kelola data ${resource.label.toLowerCase()}',
      headerActions: [
        if (hasCreate)
          FilledButton.icon(
            onPressed: () => context.go(pathFor('create')),
            icon: const Icon(Icons.add, size: 16),
            label: Text('Tambah ${resource.label}'),
            style: FilledButton.styleFrom(
              backgroundColor:
                  FilamentThemeScope.of(context).colors.primary,
            ),
          ),
      ],
      child: TableBuilderWidget<T>(
        schema: resource.table(),
        dataSource: resource.dataSource,
        idOf: resource.recordId,
        onRowTap: (row) => context.go(pathFor(resource.recordId(row))),
      ),
    );
  }
}
