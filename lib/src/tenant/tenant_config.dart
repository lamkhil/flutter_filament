import '../resource/resource.dart';

/// Konfigurasi multi-tenancy untuk [Panel]. Generic `T` = model tenant
/// (mis. `Lokasi`, `Team`, `Organization`), sehingga konsumen bebas
/// memilih apa yang dipakai sebagai "tenant".
///
/// Mirip Filament 5:
/// ```php
/// Panel::make('admin')->tenant(Team::class, slugAttribute: 'slug')
/// ```
class TenantConfig<T> {
  /// Resource yang menyediakan daftar & CRUD tenant itu sendiri.
  /// Contoh: `LokasiResource()`.
  final Resource<T> resource;

  /// Nama field di dokumen resource lain yang merujuk ke tenant.
  /// Contoh: semua Zona punya `lokasiId`, jadi `scopeField: 'lokasiId'`.
  /// [FirestoreDataSource] akan otomatis `where(scopeField, = currentTenantId)`.
  final String scopeField;

  /// Label singkat untuk satu tenant (dipakai di switcher & breadcrumb).
  final String Function(T tenant) labelOf;

  /// Apa yang dipakai di URL — biasanya `id` tapi bisa `slug`. Default: `id`.
  final String Function(T tenant) slugOf;

  /// Lookup tenant by slug (kebalikan dari [slugOf]). Default: resource.dataSource.get.
  /// Biarkan `null` kalau slug-nya sama dengan id.
  final Future<T?> Function(String slug)? resolveBySlug;

  /// Apakah resource tenant ini sendiri di-scope? Default: `false`
  /// (LokasiResource di-access global, bukan per-lokasi).
  final bool scopeSelf;

  const TenantConfig({
    required this.resource,
    required this.scopeField,
    required this.labelOf,
    required this.slugOf,
    this.resolveBySlug,
    this.scopeSelf = false,
  });
}
