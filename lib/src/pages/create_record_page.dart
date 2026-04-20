import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../forms/form_builder_widget.dart';
import '../forms/form_state.dart';
import '../layout/panel_layout.dart';
import '../resource/resource.dart';
import '../resource/resource_context.dart';
import '../theme/filament_theme.dart';

/// Create page of a [Resource].
class CreateRecordPage<T> extends StatefulWidget {
  final Resource<T> resource;
  const CreateRecordPage({super.key, required this.resource});

  @override
  State<CreateRecordPage<T>> createState() => _CreateRecordPageState<T>();
}

class _CreateRecordPageState<T> extends State<CreateRecordPage<T>> {
  final _state = FormStateController();
  bool _saving = false;

  Future<void> _save() async {
    final schema = widget.resource.form(
      ResourceContext<T>(operation: ResourceOperation.create),
    );
    if (!schema.validate(_state)) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    try {
      final record = await widget.resource.dataSource
          .create(schema.extractValues(_state));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${widget.resource.label} "${widget.resource.recordTitle(record)}" dibuat')),
      );
      context.goNamed('${widget.resource.slug}.list');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schema = widget.resource.form(
      ResourceContext<T>(operation: ResourceOperation.create),
    );
    final theme = FilamentThemeScope.of(context);
    return PanelLayout(
      title: 'Tambah ${widget.resource.label}',
      subtitle: 'Buat data ${widget.resource.label.toLowerCase()} baru',
      headerActions: [
        OutlinedButton(
          onPressed: () => context.goNamed('${widget.resource.slug}.list'),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        child: FormBuilderWidget(schema: schema, state: _state),
      ),
    );
  }
}
