/// Interface yang di-implement aplikasi untuk memberitahu flutter_filament
/// tenant apa saja yang boleh diakses user yang sedang login.
///
/// Contoh di project Antrian:
/// ```dart
/// class AntrianTenantAccess extends TenantAccess {
///   @override
///   Future<TenantPermissions> permissions() async {
///     final uid = FirebaseAuth.instance.currentUser?.uid;
///     final doc = await FirebaseFirestore.instance
///         .collection('users').doc(uid).get();
///     final data = doc.data() ?? {};
///     return TenantPermissions(
///       isGlobalAdmin: data['role'] == 'admin',
///       allowedIds: List<String>.from(data['lokasiIds'] ?? const []),
///     );
///   }
/// }
/// ```
abstract class TenantAccess {
  /// Dipanggil setelah login / saat panel pertama load untuk menentukan
  /// tenant mana saja yang user punya akses.
  Future<TenantPermissions> permissions();
}

class TenantPermissions {
  /// User ini admin global — bypass tenant scoping sama sekali,
  /// data source tidak menambahkan `where(scopeField)`.
  final bool isGlobalAdmin;

  /// Daftar tenant id yang user punya akses (diabaikan kalau [isGlobalAdmin] true).
  final List<String> allowedIds;

  const TenantPermissions({
    required this.isGlobalAdmin,
    required this.allowedIds,
  });

  static const empty = TenantPermissions(
    isGlobalAdmin: false,
    allowedIds: [],
  );

  bool canAccess(String tenantId) => isGlobalAdmin || allowedIds.contains(tenantId);
}
