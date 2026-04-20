import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../resource/resource.dart';
import '../tables/table_builder_widget.dart';
import '../theme/filament_theme.dart';
import '../layout/panel_layout.dart';

/// The list page of a [Resource]. Renders the resource's [TableSchema] and
/// provides a header action to navigate to the create page (if declared).
class ListRecordsPage<T> extends StatelessWidget {
  final Resource<T> resource;
  const ListRecordsPage({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final hasCreate = resource
        .pages()
        .any((p) => p.name == 'create');
    return PanelLayout(
      title: resource.pluralLabel,
      subtitle: 'Kelola data ${resource.label.toLowerCase()}',
      headerActions: [
        if (hasCreate)
          FilledButton.icon(
            onPressed: () =>
                context.goNamed('${resource.slug}.create'),
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
        onRowTap: (row) {
          context.goNamed(
            '${resource.slug}.view',
            pathParameters: {'id': resource.recordId(row)},
          );
        },
      ),
    );
  }
}
