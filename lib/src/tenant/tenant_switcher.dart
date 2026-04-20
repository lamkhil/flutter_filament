import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/paginated_result.dart';
import '../panel/panel_provider.dart';
import '../theme/filament_theme.dart';
import 'tenant_scope.dart';

/// Dropdown di topbar untuk pindah tenant (`Lokasi`, `Team`, dst).
///
/// Behavior:
/// - Hidden kalau panel tidak multi-tenant.
/// - Hidden kalau user cuma punya akses ke 1 tenant (auto-selected di redirect).
/// - Global admin → list dari [TenantConfig.resource.dataSource] (semua tenant).
/// - User biasa → list dari `allowedIds` di permissions, difilter.
/// - Klik tenant → `context.go('<panelPath>/<newTenantId>')` (kembali ke dashboard).
class TenantSwitcher extends StatefulWidget {
  const TenantSwitcher({super.key});

  @override
  State<TenantSwitcher> createState() => _TenantSwitcherState();
}

class _TenantSwitcherState extends State<TenantSwitcher> {
  List<({String id, String label})>? _options;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_options == null && !_loading) _load();
  }

  Future<void> _load() async {
    final panel = PanelProvider.maybeOf(context);
    final scope = TenantScopeProvider.maybeOf(context);
    if (panel == null || scope == null) return;
    final cfg = panel.tenant;
    if (cfg == null) return;
    setState(() => _loading = true);

    final perms = scope.permissions;
    final all = await cfg.resource.dataSource
        .list(const ListQuery(perPage: 500))
        .then((r) => r.data);

    final filtered = perms.isGlobalAdmin
        ? all
        : all.where((r) => perms.allowedIds.contains(cfg.slugOf(r))).toList();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _options = filtered
          .map((r) => (id: cfg.slugOf(r), label: cfg.labelOf(r)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final panel = PanelProvider.maybeOf(context);
    if (panel == null || !panel.isMultiTenant) return const SizedBox.shrink();

    final scope = TenantScopeProvider.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final opts = _options ?? const [];
    final isAdmin = scope.permissions.isGlobalAdmin;
    // Hide kalau cuma 1 pilihan & bukan admin (auto-selected, tanpa pilihan).
    if (!isAdmin && opts.length <= 1) {
      return const SizedBox.shrink();
    }
    final theme = FilamentThemeScope.of(context);
    final currentId = scope.currentId; // null = admin di /admin (semua data)

    // Sentinel untuk opsi "Semua <label>" admin.
    const allSentinel = '__all__';
    final currentValue = (isAdmin && currentId == null) ? allSentinel : currentId;

    String currentLabel;
    if (isAdmin && currentId == null) {
      currentLabel = 'Semua ${panel.tenant!.resource.pluralLabel.toLowerCase()}';
    } else {
      currentLabel = opts
          .firstWhere(
            (o) => o.id == currentId,
            orElse: () => (id: '', label: 'Pilih...'),
          )
          .label;
    }

    return PopupMenuButton<String>(
      tooltip: 'Pindah ${panel.tenant!.resource.label.toLowerCase()}',
      position: PopupMenuPosition.under,
      onSelected: (newId) {
        if (newId == currentValue) return;
        if (newId == allSentinel) {
          context.go(panel.path); // admin: root dashboard, no scope
        } else {
          context.go('${panel.path}/$newId');
        }
      },
      itemBuilder: (ctx) => [
        if (isAdmin)
          PopupMenuItem<String>(
            value: allSentinel,
            child: Row(
              children: [
                Icon(
                  currentValue == allSentinel
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 16,
                  color: currentValue == allSentinel
                      ? theme.colors.primary
                      : theme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Semua ${panel.tenant!.resource.pluralLabel.toLowerCase()}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        if (isAdmin) const PopupMenuDivider(),
        for (final o in opts)
          PopupMenuItem<String>(
            value: o.id,
            child: Row(
              children: [
                Icon(
                  o.id == currentValue
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 16,
                  color: o.id == currentValue
                      ? theme.colors.primary
                      : theme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(o.label),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(panel.tenant!.resource.icon,
                size: 16, color: theme.colors.primary),
            const SizedBox(width: 8),
            Text(
              _loading ? 'Memuat...' : currentLabel,
              style: TextStyle(color: theme.textPrimary, fontSize: 13),
            ),
            const SizedBox(width: 6),
            Icon(Icons.unfold_more, size: 14, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }
}

