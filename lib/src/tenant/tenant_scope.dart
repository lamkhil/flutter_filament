import 'package:flutter/widgets.dart';
import 'tenant_access.dart';

/// State holder global untuk tenancy:
/// - `currentId` — tenant yang aktif saat ini (dari URL path param)
/// - `permissions` — hasil [TenantAccess.permissions] (allowed list + admin flag)
///
/// Dua cara akses:
/// 1. Via widget tree: [TenantScopeProvider.of(context)] — rebuild aware.
/// 2. Via static: [TenantScope.currentId] / [TenantScope.adminBypass] —
///    dipakai oleh [FirestoreDataSource] yang bukan widget.
///
/// Static mirror di-update setiap kali inherited widget rebuild, jadi selalu
/// sinkron dengan sumber kebenaran (URL path param).
class TenantScope extends ChangeNotifier {
  String? _currentId;
  TenantPermissions _permissions = TenantPermissions.empty;
  bool _loading = true;

  String? get currentId => _currentId;
  TenantPermissions get permissions => _permissions;
  bool get loading => _loading;
  bool get adminBypass => _permissions.isGlobalAdmin;

  /// Static mirror dipakai oleh kode non-widget (data source).
  static String? _staticCurrentId;
  static bool _staticAdminBypass = false;

  static String? get currentIdStatic => _staticCurrentId;
  static bool get adminBypassStatic => _staticAdminBypass;

  void setCurrentId(String? id) {
    if (_currentId == id) return;
    _currentId = id;
    _staticCurrentId = id;
    notifyListeners();
  }

  void setPermissions(TenantPermissions p) {
    _permissions = p;
    _staticAdminBypass = p.isGlobalAdmin;
    _loading = false;
    notifyListeners();
  }

  void markLoading() {
    if (_loading) return;
    _loading = true;
    notifyListeners();
  }
}

/// InheritedNotifier untuk mengekspos [TenantScope] ke subtree.
class TenantScopeProvider extends InheritedNotifier<TenantScope> {
  const TenantScopeProvider({
    super.key,
    required TenantScope super.notifier,
    required super.child,
  });

  static TenantScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TenantScopeProvider>()
        ?.notifier;
    assert(scope != null, 'No TenantScopeProvider in context.');
    return scope!;
  }

  static TenantScope? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<TenantScopeProvider>()
      ?.notifier;
}
