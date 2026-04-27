import 'package:flutter/material.dart';

import '../resource/relation_manager.dart';
import '../tables/table_builder_widget.dart';
import '../theme/filament_theme.dart';

/// Renders a list of [RelationManager]s as a tab section, used by
/// edit/view record pages to show related collections.
class RelationTabs extends StatefulWidget {
  /// The parent record. Forwarded to each manager's `table(parent)` and
  /// `dataSource(parent)` calls. Typed as `dynamic` so the widget can host
  /// managers of mixed parent types (rare, but the framework treats the
  /// list of managers as untyped at the resource level).
  final dynamic parent;

  final List<RelationManager> managers;

  /// Inner content height. Tab content scrolls within this box.
  final double height;

  const RelationTabs({
    super.key,
    required this.parent,
    required this.managers,
    this.height = 480,
  });

  @override
  State<RelationTabs> createState() => _RelationTabsState();
}

class _RelationTabsState extends State<RelationTabs>
    with TickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: widget.managers.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant RelationTabs old) {
    super.didUpdateWidget(old);
    if (old.managers.length != widget.managers.length) {
      _tab.dispose();
      _tab = TabController(length: widget.managers.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.managers.isEmpty) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: theme.colors.primary,
              unselectedLabelColor: theme.textSecondary,
              indicatorColor: theme.colors.primary,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final m in widget.managers)
                  Tab(
                    icon: m.icon != null ? Icon(m.icon, size: 16) : null,
                    text: m.title,
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),
          SizedBox(
            height: widget.height,
            child: TabBarView(
              controller: _tab,
              children: [
                for (final m in widget.managers)
                  _RelationContent(parent: widget.parent, manager: m),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationContent extends StatelessWidget {
  final dynamic parent;
  final RelationManager manager;
  const _RelationContent({required this.parent, required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final schema = manager.table(parent);
    final ds = manager.dataSource(parent);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (manager.description != null) ...[
            Text(
              manager.description!,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: TableBuilderWidget(
              schema: schema,
              dataSource: ds,
              idOf: (r) => manager.childId(r),
            ),
          ),
        ],
      ),
    );
  }
}
