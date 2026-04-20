import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:go_router/go_router.dart';

/// Minimal example: one resource (Produk) with an in-memory data source
/// and a stat widget on the dashboard.
void main() {
  final panel = Panel(
    id: 'admin',
    path: '/admin',
    brandName: 'Filament Demo',
    theme: const FilamentTheme(colors: FilamentColors.indigo),
    resources: [ProdukResource()],
    widgets: const [TotalProdukWidget()],
  );

  final router = GoRouter(
    initialLocation: '/admin',
    routes: panel.buildRoutes(),
  );

  runApp(MaterialApp.router(
    title: 'Filament Demo',
    theme: panel.theme.toThemeData(),
    routerConfig: router,
    debugShowCheckedModeBanner: false,
  ));
}

// --- Model ---------------------------------------------------------------

class Produk {
  final String id;
  final String nama;
  final int harga;
  final bool aktif;

  const Produk({
    required this.id,
    required this.nama,
    required this.harga,
    required this.aktif,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'nama': nama, 'harga': harga, 'aktif': aktif};

  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
        id: json['id']?.toString() ?? '',
        nama: (json['nama'] as String?) ?? '',
        harga: (json['harga'] as num?)?.toInt() ?? 0,
        aktif: (json['aktif'] as bool?) ?? true,
      );
}

// --- Service (in-memory) -------------------------------------------------

final produkDataSource = MemoryDataSource<Produk>(
  idOf: (p) => p.id,
  toMap: (p) => p.toJson(),
  fromMap: Produk.fromJson,
  seed: const [
    Produk(id: '1', nama: 'Kopi Susu', harga: 18000, aktif: true),
    Produk(id: '2', nama: 'Teh Tarik', harga: 15000, aktif: true),
    Produk(id: '3', nama: 'Roti Bakar', harga: 22000, aktif: false),
  ],
);

// --- Resource ------------------------------------------------------------

class ProdukResource extends Resource<Produk> {
  @override
  String get slug => 'produk';
  @override
  String get label => 'Produk';
  @override
  String get pluralLabel => 'Produk';
  @override
  IconData get icon => Icons.inventory_2_outlined;

  @override
  DataSource<Produk> get dataSource => produkDataSource;

  @override
  String recordId(Produk r) => r.id;

  @override
  String recordTitle(Produk r) => r.nama;

  @override
  Map<String, dynamic> toFormData(Produk r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Produk> ctx) => FormSchema(
        columns: 2,
        components: [
          TextInput(
            name: 'nama',
            label: 'Nama',
            required: true,
            columnSpan: 2,
          ),
          NumberInput(
            name: 'harga',
            label: 'Harga',
            prefix: 'Rp ',
            required: true,
          ),
          Toggle(name: 'aktif', label: 'Aktif', defaultValue: true),
        ],
      );

  @override
  TableSchema<Produk> table() => TableSchema<Produk>(
        defaultSort: 'nama',
        columns: [
          TextColumn<Produk>(
            name: 'nama',
            label: 'Nama',
            accessor: (r) => r.nama,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<Produk>(
            name: 'harga',
            label: 'Harga',
            accessor: (r) => r.harga,
            formatter: (r) => 'Rp ${r.harga}',
            sortable: true,
          ),
          BooleanColumn<Produk>(
            name: 'aktif',
            label: 'Aktif',
            accessor: (r) => r.aktif,
          ),
        ],
        rowActions: [
          RowAction.delete<Produk>((ctx, row) async {
            await produkDataSource.delete(row.id);
          }),
        ],
      );
}

// --- Dashboard widget ----------------------------------------------------

class TotalProdukWidget extends DashboardWidget {
  const TotalProdukWidget({super.key});

  @override
  int get columnSpan => 12;

  @override
  Widget build(BuildContext context) => const StatWidget(
        stats: [
          Stat(
            label: 'Total produk',
            value: '3',
            icon: Icons.inventory,
            description: 'dari in-memory data source',
          ),
          Stat(
            label: 'Produk aktif',
            value: '2',
            icon: Icons.check_circle_outline,
            delta: 15.3,
          ),
          Stat(
            label: 'Nonaktif',
            value: '1',
            icon: Icons.cancel_outlined,
          ),
        ],
      );
}
