import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/panel_layout.dart';
import '../panel/panel_provider.dart';
import '../resource/resource.dart';
import '../resource/resource_context.dart';
import '../tenant/tenant_scope.dart';
import '../theme/filament_theme.dart';

/// Read-only detail page of a [Resource]. Renders each field from the
/// form schema as a static label/value row.
class ViewRecordPage<T> extends StatefulWidget {
  final Resource<T> resource;
  final String recordId;
  const ViewRecordPage({
    super.key,
    required this.resource,
    required this.recordId,
  });

  @override
  State<ViewRecordPage<T>> createState() => _ViewRecordPageState<T>();
}

class _ViewRecordPageState<T> extends State<ViewRecordPage<T>> {
  T? _record;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await widget.resource.dataSource.get(widget.recordId);
      if (!mounted) return;
      setState(() {
        _record = r;
        _loading = false;
        if (r == null) _error = StateError('Tidak ditemukan');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    if (_loading) {
      return const PanelLayout(
        title: 'Memuat...',
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _record == null) {
      return PanelLayout(
        title: 'Error',
        child: Center(child: Text('$_error')),
      );
    }
    final data = widget.resource.toFormData(_record as T);
    final schema = widget.resource.form(ResourceContext<T>(
      operation: ResourceOperation.view,
      record: _record,
    ));
    final hasEdit = widget.resource.pages().any((p) => p.name == 'edit');
    final panel = PanelProvider.of(context);
    final tenantId = TenantScopeProvider.maybeOf(context)?.currentId;
    final unscoped = panel.isTenantResourceSlug(widget.resource.slug);
    final listPath = panel.resourcePath(
      widget.resource.slug,
      tenantId: tenantId,
      unscoped: unscoped,
    );
    final editPath = panel.resourcePath(
      widget.resource.slug,
      subPath: '${widget.recordId}/edit',
      tenantId: tenantId,
      unscoped: unscoped,
    );

    return PanelLayout(
      title: widget.resource.recordTitle(_record as T),
      subtitle: 'Detail ${widget.resource.label.toLowerCase()}',
      headerActions: [
        OutlinedButton.icon(
          onPressed: () => context.go(listPath),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Kembali'),
        ),
        if (hasEdit)
          FilledButton.icon(
            onPressed: () => context.go(editPath),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: FilledButton.styleFrom(
                backgroundColor: theme.colors.primary),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final field in schema.fields)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _DetailRow(
                  label: field.label,
                  value: _formatValue(data[field.name]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic v) {
    if (v == null) return '-';
    if (v is bool) return v ? 'Ya' : 'Tidak';
    if (v is DateTime) return v.toLocal().toString();
    return v.toString();
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: theme.textPrimary),
          ),
        ),
      ],
    );
  }
}
