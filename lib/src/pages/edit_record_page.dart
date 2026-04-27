import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../forms/form_builder_widget.dart';
import '../forms/form_state.dart';
import '../layout/panel_layout.dart';
import '../panel/panel_provider.dart';
import '../resource/resource.dart';
import '../resource/resource_context.dart';
import '../tenant/tenant_scope.dart';
import '../theme/filament_theme.dart';
import '../widgets/relation_tabs.dart';

/// Edit page of a [Resource]. Loads record by id, mutates via data source.
class EditRecordPage<T> extends StatefulWidget {
  final Resource<T> resource;
  final String recordId;
  const EditRecordPage({
    super.key,
    required this.resource,
    required this.recordId,
  });

  @override
  State<EditRecordPage<T>> createState() => _EditRecordPageState<T>();
}

class _EditRecordPageState<T> extends State<EditRecordPage<T>> {
  final _state = FormStateController();
  T? _record;
  bool _loading = true;
  bool _saving = false;
  Object? _error;

  void _goBackToList() {
    final panel = PanelProvider.of(context);
    final tenantId = TenantScopeProvider.maybeOf(context)?.currentId;
    final unscoped = panel.isTenantResourceSlug(widget.resource.slug);
    context.go(panel.resourcePath(
      widget.resource.slug,
      tenantId: tenantId,
      unscoped: unscoped,
    ));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final record = await widget.resource.dataSource.get(widget.recordId);
      if (!mounted) return;
      if (record == null) {
        setState(() {
          _error = StateError('Data tidak ditemukan');
          _loading = false;
        });
        return;
      }
      _state.setAll(widget.resource.toFormData(record));
      setState(() {
        _record = record;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final schema = widget.resource.form(
      ResourceContext<T>(
        operation: ResourceOperation.edit,
        record: _record,
      ),
    );
    if (!schema.validate(_state)) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await widget.resource.dataSource.update(
        widget.recordId,
        schema.extractValues(_state),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${widget.resource.label} "${widget.resource.recordTitle(updated)}" diperbarui')),
      );
      _goBackToList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data?'),
        content: const Text('Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.resource.dataSource.delete(widget.recordId);
      if (!mounted) return;
      _goBackToList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
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
    final schema = widget.resource.form(
      ResourceContext<T>(
        operation: ResourceOperation.edit,
        record: _record,
      ),
    );
    return PanelLayout(
      title: 'Edit ${widget.resource.label}',
      subtitle: widget.resource.recordTitle(_record as T),
      headerActions: [
        IconButton(
          tooltip: 'Hapus',
          icon: Icon(Icons.delete_outline, color: theme.colors.danger),
          onPressed: _delete,
        ),
        OutlinedButton(
          onPressed: _goBackToList,
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save, size: 16),
          label: const Text('Simpan'),
          style:
              FilledButton.styleFrom(backgroundColor: theme.colors.primary),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(theme.borderRadius),
            ),
            child: FormBuilderWidget(schema: schema, state: _state),
          ),
          if (widget.resource.relations().isNotEmpty)
            RelationTabs(
              parent: _record,
              managers: widget.resource.relations(),
            ),
        ],
      ),
    );
  }
}
