import 'package:flutter/material.dart';
import '../actions/action.dart';
import '../actions/row_action.dart';
import '../data/data_source.dart';
import '../data/paginated_result.dart';
import '../theme/filament_theme.dart';
import 'table_column.dart';
import 'table_schema.dart';

/// Renders a [TableSchema] backed by a [DataSource].
/// Supports: search, sort, filter, pagination, row actions, header actions.
class TableBuilderWidget<T> extends StatefulWidget {
  final TableSchema<T> schema;
  final DataSource<T> dataSource;
  final String Function(T row) idOf;
  final void Function(T row)? onRowTap;

  const TableBuilderWidget({
    super.key,
    required this.schema,
    required this.dataSource,
    required this.idOf,
    this.onRowTap,
  });

  @override
  State<TableBuilderWidget<T>> createState() => _TableBuilderWidgetState<T>();
}

class _TableBuilderWidgetState<T> extends State<TableBuilderWidget<T>> {
  late ListQuery _query;
  PaginatedResult<T>? _result;
  bool _loading = true;
  Object? _error;
  final _searchCtrl = TextEditingController();
  final Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _query = ListQuery(
      perPage: widget.schema.defaultPerPage,
      sortBy: widget.schema.defaultSort,
      sortDesc: widget.schema.defaultSortDesc,
    );
    _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.dataSource.list(_query);
      if (!mounted) return;
      setState(() {
        _result = result;
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

  void _updateQuery(ListQuery Function(ListQuery) updater) {
    setState(() => _query = updater(_query));
    _fetch();
  }

  void _toggleSort(String column) {
    if (_query.sortBy == column) {
      if (!_query.sortDesc) {
        _updateQuery((q) => q.copyWith(sortDesc: true));
      } else {
        _updateQuery((q) => q.copyWith(sortBy: null, sortDesc: false));
      }
    } else {
      _updateQuery((q) => q.copyWith(sortBy: column, sortDesc: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(
          searchController: _searchCtrl,
          schema: widget.schema,
          filters: _filters,
          onSearchChanged: (q) => _updateQuery((qq) =>
              qq.copyWith(page: 1, search: q.isEmpty ? null : q)),
          onFilterChanged: (name, value) {
            setState(() {
              if (value == null) {
                _filters.remove(name);
              } else {
                _filters[name] = value;
              }
            });
            _updateQuery((qq) =>
                qq.copyWith(page: 1, filters: Map.of(_filters)));
          },
          onRefresh: refresh,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: theme.border),
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          child: Column(
            children: [
              _buildHeader(theme),
              const Divider(height: 1),
              _buildBody(theme),
              if (widget.schema.paginated) ...[
                const Divider(height: 1),
                _buildFooter(theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(FilamentTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (final col in widget.schema.columns)
            Expanded(
              flex: (col.width ?? 1).toInt() == 0 ? 1 : 1,
              child: _HeaderCell(
                column: col,
                sortActive: _query.sortBy == col.name,
                sortDesc: _query.sortDesc,
                onTap: col.sortable ? () => _toggleSort(col.name) : null,
              ),
            ),
          if (widget.schema.rowActions.isNotEmpty)
            SizedBox(
              width: 48.0 * widget.schema.rowActions.length,
              child: Text(
                '',
                textAlign: TextAlign.end,
                style: TextStyle(color: theme.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(FilamentTheme theme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: theme.colors.danger, size: 36),
              const SizedBox(height: 8),
              Text('$_error', style: TextStyle(color: theme.textSecondary)),
            ],
          ),
        ),
      );
    }
    final rows = _result?.data ?? [];
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: theme.textMuted),
              const SizedBox(height: 8),
              Text(
                widget.schema.emptyTitle ?? 'Belum ada data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              if (widget.schema.emptyDescription != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.schema.emptyDescription!,
                    style: TextStyle(color: theme.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _RowView<T>(
            row: rows[i],
            isLast: i == rows.length - 1,
            schema: widget.schema,
            onTap: widget.onRowTap == null
                ? null
                : () => widget.onRowTap!(rows[i]),
            onActionFinished: refresh,
          ),
      ],
    );
  }

  Widget _buildFooter(FilamentTheme theme) {
    final r = _result;
    if (r == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Menampilkan ${r.data.length} dari ${r.total} data',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          DropdownButton<int>(
            value: _query.perPage,
            items: widget.schema.perPageOptions
                .map((n) => DropdownMenuItem(value: n, child: Text('$n / hal')))
                .toList(),
            onChanged: (v) => v == null
                ? null
                : _updateQuery((q) => q.copyWith(perPage: v, page: 1)),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: r.hasPrev
                ? () => _updateQuery((q) => q.copyWith(page: q.page - 1))
                : null,
          ),
          Text('${r.page} / ${r.totalPages}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: r.hasNext
                ? () => _updateQuery((q) => q.copyWith(page: q.page + 1))
                : null,
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final TableColumn column;
  final bool sortActive;
  final bool sortDesc;
  final VoidCallback? onTap;

  const _HeaderCell({
    required this.column,
    required this.sortActive,
    required this.sortDesc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.textSecondary,
      letterSpacing: 0.3,
    );
    final content = Row(
      mainAxisAlignment: column.align == ColumnAlign.end
          ? MainAxisAlignment.end
          : column.align == ColumnAlign.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(column.label.toUpperCase(), style: style),
        if (column.sortable) ...[
          const SizedBox(width: 4),
          Icon(
            sortActive
                ? (sortDesc ? Icons.arrow_downward : Icons.arrow_upward)
                : Icons.unfold_more,
            size: 12,
            color:
                sortActive ? theme.colors.primary : theme.textSecondary,
          ),
        ],
      ],
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}

class _RowView<T> extends StatelessWidget {
  final T row;
  final bool isLast;
  final TableSchema<T> schema;
  final VoidCallback? onTap;
  final Future<void> Function() onActionFinished;

  const _RowView({
    required this.row,
    required this.isLast,
    required this.schema,
    required this.onActionFinished,
    this.onTap,
  });

  Color _actionColor(ActionColor c, FilamentTheme theme) {
    switch (c) {
      case ActionColor.primary:
        return theme.colors.primary;
      case ActionColor.success:
        return theme.colors.success;
      case ActionColor.warning:
        return theme.colors.warning;
      case ActionColor.danger:
        return theme.colors.danger;
      case ActionColor.info:
        return theme.colors.info;
      case ActionColor.gray:
        return theme.colors.gray;
    }
  }

  Future<void> _runAction(BuildContext context, RowAction<T> action) async {
    if (action.requiresConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(action.confirmationTitle ?? 'Konfirmasi'),
          content: Text(action.confirmationMessage ?? 'Lanjutkan aksi?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ya')),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    if (!context.mounted) return;
    await action.onPressed(context, row);
    await onActionFinished();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: theme.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final col in schema.columns)
              Expanded(
                child: Align(
                  alignment: col.align == ColumnAlign.end
                      ? Alignment.centerRight
                      : col.align == ColumnAlign.center
                          ? Alignment.center
                          : Alignment.centerLeft,
                  child: col.build(context, row),
                ),
              ),
            if (schema.rowActions.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final action in schema.rowActions)
                    if (action.isVisible(row))
                      IconButton(
                        tooltip: action.label,
                        icon: Icon(
                          action.icon ?? Icons.more_horiz,
                          size: 18,
                          color: _actionColor(action.color, theme),
                        ),
                        onPressed: () => _runAction(context, action),
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar<T> extends StatelessWidget {
  final TextEditingController searchController;
  final TableSchema<T> schema;
  final Map<String, dynamic> filters;
  final void Function(String) onSearchChanged;
  final void Function(String name, dynamic value) onFilterChanged;
  final Future<void> Function() onRefresh;

  const _Toolbar({
    required this.searchController,
    required this.schema,
    required this.filters,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  Color _actionColor(ActionColor c, FilamentTheme theme) {
    switch (c) {
      case ActionColor.primary:
        return theme.colors.primary;
      case ActionColor.success:
        return theme.colors.success;
      case ActionColor.warning:
        return theme.colors.warning;
      case ActionColor.danger:
        return theme.colors.danger;
      case ActionColor.info:
        return theme.colors.info;
      case ActionColor.gray:
        return theme.colors.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);

    final leftSide = <Widget>[
      if (schema.searchable)
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: schema.searchPlaceholder ?? 'Cari...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius),
                borderSide: BorderSide(color: theme.border),
              ),
            ),
          ),
        ),
      for (final f in schema.filters)
        SizedBox(
          width: 180,
          child: DropdownButtonFormField(
            initialValue: filters[f.name],
            decoration: InputDecoration(
              labelText: f.label,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua')),
              for (final o in f.options)
                DropdownMenuItem(value: o.value, child: Text(o.label)),
            ],
            onChanged: (v) => onFilterChanged(f.name, v),
          ),
        ),
    ];

    final rightSide = <Widget>[
      IconButton(
        tooltip: 'Muat ulang',
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
      ),
      for (final a in schema.headerActions)
        FilledButton.icon(
          onPressed: () => a.onPressed(context),
          icon: Icon(a.icon ?? Icons.add, size: 16),
          label: Text(a.label),
          style: FilledButton.styleFrom(
            backgroundColor: _actionColor(a.color, theme),
          ),
        ),
    ];

    final leftWrap = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: leftSide,
    );
    final rightWrap = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: rightSide,
    );

    return LayoutBuilder(
      builder: (ctx, c) {
        final narrow = c.maxWidth < 600;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leftWrap,
              const SizedBox(height: 8),
              rightWrap,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: leftWrap),
            rightWrap,
          ],
        );
      },
    );
  }
}
