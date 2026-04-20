# flutter_filament

[![pub package](https://img.shields.io/pub/v/flutter_filament.svg)](https://pub.dev/packages/flutter_filament)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

Framework admin panel untuk Flutter yang terinspirasi [Filament 5](https://filamentphp.com/).
Bangun panel admin lengkap dengan **Panel**, **Resource**, **Form schema**,
**Table schema**, dan **Dashboard widget** — semua schema-driven, tanpa perlu
menulis UI CRUD manual.

## Fitur

- **Panel** sebagai pondasi, satu aplikasi boleh punya banyak panel.
- **Resource\<T\>** otomatis men-generate 4 halaman: list, create, edit, view.
- **FormSchema** builder dengan komponen reaktif: `TextInput`, `Textarea`,
  `Select`, `Toggle`, `Checkbox`, `DatePicker`, `NumberInput`, `Section`, `Grid`.
- **TableSchema** dengan search, sort, filter, pagination, row/header/bulk actions.
- **Dashboard widget**: `StatWidget`, `ChartWidget`, `TableDashboardWidget`, grid 12 kolom.
- **DataSource\<T\>** abstrak — backend bebas (Firestore, REST, GraphQL, in-memory).
- **Mason bricks** untuk scaffolding model/resource/page/widget dari CLI.
- Tema lengkap (amber, blue, emerald, rose, indigo, slate) + dark mode.

## Daftar isi

1. [Instalasi](#instalasi)
2. [Quick start](#quick-start)
3. [Peta konsep Filament → flutter_filament](#peta-konsep)
4. [Panel](#panel)
5. [Resource](#resource)
6. [FormSchema + komponen](#formschema--komponen)
7. [TableSchema + kolom + action](#tableschema--kolom--action)
8. [Dashboard widget](#dashboard-widget)
9. [FilamentPage (halaman kustom)](#filamentpage-halaman-kustom)
10. [DataSource](#datasource)
11. [Theme](#theme)
12. [Mason bricks (CLI scaffolding)](#mason-bricks-cli-scaffolding)
13. [Contributing](#contributing)
14. [Lisensi](#lisensi)

---

## Instalasi

```bash
flutter pub add flutter_filament
```

atau manual di `pubspec.yaml`:

```yaml
dependencies:
  flutter_filament: ^0.1.0
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_filament/flutter_filament.dart';

final adminPanel = Panel(
  id: 'admin',
  path: '/admin',
  brandName: 'My App',
  theme: const FilamentTheme(colors: FilamentColors.amber),
  resources: [ProdukResource()],
  widgets: const [TotalPenjualanWidget()],
);

final router = GoRouter(routes: adminPanel.buildRoutes());

void main() => runApp(MaterialApp.router(routerConfig: router));
```

Jalankan, buka `/admin`. Sidebar otomatis terbentuk dari `resources` dan `widgets`.

> Lihat folder [`example/`](example) untuk demo app lengkap yang bisa langsung
> dijalankan.

---

## Peta konsep

| Filament 5 (PHP) | flutter_filament (Dart) |
|---|---|
| `Panel::make('admin')` | `Panel(id: 'admin', ...)` |
| `Resource::class` | `class FooResource extends Resource<Foo>` |
| `Form::schema([...])` | `FormSchema(components: [...])` |
| `Table::columns([...])` | `TableSchema<T>(columns: [...])` |
| `TextInput::make('name')->required()` | `TextInput(name: 'name', required: true)` |
| `Select::make('status')->options([...])` | `Select(name: 'status', options: [...])` |
| `Toggle`, `Checkbox`, `DatePicker`, `Textarea` | nama sama |
| `Section::make('Info')->schema([...])` | `Section(title: 'Info', children: [...])` |
| `Grid::make(2)` | `Grid(columns: 2, children: [...])` |
| `TextColumn::make('name')->searchable()` | `TextColumn(name: 'name', searchable: true)` |
| `BadgeColumn`, `IconColumn`, `BooleanColumn` | nama sama |
| `Action`, `BulkAction`, `HeaderAction` | `RowAction`, `BulkAction`, `HeaderAction` |
| `StatsOverviewWidget` | `StatWidget(stats: [...])` |
| `ChartWidget`, `TableWidget` | `ChartWidget`, `TableDashboardWidget` |
| `ListRecords`, `CreateRecord`, `EditRecord`, `ViewRecord` | otomatis — `Resource.buildRoute()` |
| `Page::class` (standalone) | `class FooPage extends FilamentPage` |

---

## Panel

`Panel` adalah top-level container. Satu aplikasi bisa punya banyak panel
(misal `admin` dan `app`), masing-masing dengan path, theme, dan resource sendiri.

```dart
final adminPanel = Panel(
  id: 'admin',                      // unik per panel
  path: '/admin',                   // mount path di router
  brandName: 'My App',
  brandLogo: Image.asset('logo.png', width: 32),  // opsional
  theme: const FilamentTheme(
    colors: FilamentColors.amber,   // atau .blue / .emerald / .rose / .indigo / .slate
    brightness: Brightness.light,
    borderRadius: 8,
  ),
  dashboardTitle: 'Dashboard',
  dashboardIcon: Icons.dashboard_outlined,
  resources: [ProdukResource(), UserResource()],
  pages:     const [PengaturanPage()],
  widgets:   const [TotalPenjualanWidget(), GrafikMingguanWidget()],
  navigationOverride: null,         // null = auto dari resources+pages
  sidebarFooter: const SidebarFooter(),
);

final router = GoRouter(routes: [
  ...adminPanel.buildRoutes(),
  // route lain di luar panel
]);
```

`buildRoutes()` meng-generate otomatis:

- `/admin` → Dashboard (widgets)
- `/admin/<resource.slug>` → List
- `/admin/<resource.slug>/create` → Create
- `/admin/<resource.slug>/:id` → View
- `/admin/<resource.slug>/:id/edit` → Edit
- `/admin/<page.slug>` → FilamentPage kustom

---

## Resource

`Resource<T>` mengikat sebuah model ke Panel: menyediakan data source,
schema form, schema table, dan 4 halaman default.

```dart
class ProdukResource extends Resource<Produk> {
  @override String get slug => 'produk';
  @override String get label => 'Produk';
  @override String get pluralLabel => 'Produk';
  @override IconData get icon => Icons.inventory_2;
  @override String? get navigationGroup => 'Master Data';
  @override int get navigationSort => 10;

  @override
  DataSource<Produk> get dataSource => ProdukServices.dataSource;

  @override String recordId(Produk r) => r.id;
  @override String recordTitle(Produk r) => r.nama;
  @override Map<String, dynamic> toFormData(Produk r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Produk> ctx) => FormSchema(
    columns: 2,
    components: [
      Section(
        title: 'Informasi Produk',
        icon: Icons.info_outline,
        columns: 2,
        children: [
          TextInput(name: 'nama', label: 'Nama', required: true, columnSpan: 2),
          NumberInput(name: 'harga', label: 'Harga', prefix: 'Rp ', required: true),
          Select<String>(
            name: 'kategori', label: 'Kategori',
            options: const [
              SelectOption('makanan', 'Makanan'),
              SelectOption('minuman', 'Minuman'),
            ],
          ),
          Toggle(name: 'aktif', label: 'Aktif', defaultValue: true),
          Textarea(name: 'deskripsi', label: 'Deskripsi', rows: 4, columnSpan: 2),
        ],
      ),
    ],
  );

  @override
  TableSchema<Produk> table() => TableSchema<Produk>(
    defaultSort: 'nama',
    columns: [
      TextColumn<Produk>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true, sortable: true, bold: true,
      ),
      TextColumn<Produk>(
        name: 'harga', label: 'Harga',
        accessor: (r) => r.harga,
        formatter: (r) => 'Rp ${r.harga}',
        sortable: true,
      ),
      BadgeColumn<Produk>(
        name: 'kategori', label: 'Kategori',
        accessor: (r) => r.kategori,
        color: (r) => r.kategori == 'makanan' ? Colors.orange : Colors.blue,
      ),
      BooleanColumn<Produk>(
        name: 'aktif', label: 'Aktif',
        accessor: (r) => r.aktif,
      ),
    ],
    filters: [
      TableFilter(
        name: 'kategori', label: 'Kategori',
        options: const [
          TableFilterOption('makanan', 'Makanan'),
          TableFilterOption('minuman', 'Minuman'),
        ],
      ),
    ],
    rowActions: [
      RowAction.view<Produk>((ctx, row) async {}),
      RowAction.edit<Produk>((ctx, row) async {}),
      RowAction.delete<Produk>((ctx, row) async {
        await ProdukServices.dataSource.delete(row.id);
      }),
    ],
    headerActions: [
      HeaderAction(
        name: 'export', label: 'Ekspor CSV',
        icon: Icons.download,
        onPressed: (ctx) async { /* ... */ },
      ),
    ],
  );
}
```

`ResourceContext<T>` berisi `operation` (`create`/`edit`/`view`) dan `record`
saat ini, sehingga schema bisa bercabang:

```dart
FormSchema form(ResourceContext<Produk> ctx) => FormSchema(
  components: [
    TextInput(name: 'nama', label: 'Nama', required: true),
    if (ctx.isEdit) TextInput(name: 'id', label: 'ID', disabled: true),
  ],
);
```

Override halaman default kalau perlu:

```dart
@override
List<ResourcePageDef> pages() => [
  ResourcePageDef.list(),
  ResourcePageDef.create(),
  ResourcePageDef.edit(),
  ResourcePageDef.custom(
    path: 'laporan', name: 'laporan',
    builder: (ctx, state) => const ProdukLaporanPage(),
  ),
];
```

---

## FormSchema + komponen

| Komponen | Kegunaan | Filament setara |
|---|---|---|
| `TextInput` | Text satu baris | `TextInput::make()` |
| `Textarea` | Text multi-baris | `Textarea::make()` |
| `NumberInput` | Angka (int/double) dengan min/max/prefix/suffix | `TextInput::make()->numeric()` |
| `Select<T>` | Dropdown single-select | `Select::make()` |
| `Toggle` | Switch on/off | `Toggle::make()` |
| `CheckboxInput` | Checkbox | `Checkbox::make()` |
| `DatePickerInput` | Tanggal / jam / tanggal+jam | `DatePicker::make()` / `TimePicker` |
| `Section` | Card bertitel + children (bisa collapsible) | `Section::make()` |
| `Grid` | Layout N kolom untuk anak-anaknya | `Grid::make(n)` |

### Validasi & reaktivitas

```dart
TextInput(
  name: 'email', label: 'Email',
  required: true,
  rules: [
    (value, state) {
      if (value is String && !value.contains('@')) return 'Email tidak valid';
      return null;
    },
  ],
  visibleWhen: (state) => state.get<bool>('subscribe') == true,
)
```

`visibleWhen` dan `rules` menerima `FormStateController` — kamu bisa akses
nilai field lain, mirip Filament `$get('field')`.

### Render form manual (di luar resource)

```dart
final state  = FormStateController();
final schema = FormSchema(components: [
  TextInput(name: 'nama', label: 'Nama', required: true),
  NumberInput(name: 'umur', label: 'Umur'),
]);

// render
FormBuilderWidget(schema: schema, state: state)

// submit
if (!schema.validate(state)) return;
final values = schema.extractValues(state);
```

---

## TableSchema + kolom + action

| Kolom | Kegunaan |
|---|---|
| `TextColumn<T>` | Text biasa, bisa custom formatter |
| `BadgeColumn<T>` | Badge berwarna + icon opsional |
| `DateColumn<T>` | Tanggal dengan pattern `dd MMM yyyy` |
| `IconColumn<T>` | Icon driven by row |
| `BooleanColumn<T>` | ✓/✗ otomatis |

Setiap kolom bisa `searchable`, `sortable`, `align` (start/center/end),
`width`, dan menyediakan `accessor: (row) => value` untuk mengekstrak data.

### Action types

```dart
// Row — per baris
RowAction<Produk>(
  name: 'duplicate', label: 'Duplikat',
  icon: Icons.copy, color: ActionColor.info,
  requiresConfirmation: true,
  visibleWhen: (row) => row.aktif,
  onPressed: (ctx, row) async { /* ... */ },
)

// Header — atas tabel
HeaderAction(
  name: 'create', label: 'Tambah Produk',
  icon: Icons.add,
  onPressed: (ctx) async { ctx.goNamed('produk.create'); },
)

// Bulk — beberapa baris terpilih
BulkAction<Produk>(
  name: 'delete', label: 'Hapus',
  color: ActionColor.danger,
  requiresConfirmation: true,
  onPressed: (ctx, rows) async { /* ... */ },
)
```

Factory cepat untuk action standar (sudah include confirmation untuk delete):

```dart
RowAction.edit<Produk>((ctx, row) async { /* ... */ })
RowAction.view<Produk>((ctx, row) async { /* ... */ })
RowAction.delete<Produk>((ctx, row) async { /* ... */ })
```

### Render tabel manual

```dart
TableBuilderWidget<Produk>(
  schema: produkTableSchema,
  dataSource: ProdukServices.dataSource,
  idOf: (row) => row.id,
  onRowTap: (row) { /* ... */ },
)
```

---

## Dashboard widget

### StatWidget — baris statistik

```dart
class TotalPenjualanWidget extends DashboardWidget {
  const TotalPenjualanWidget();

  @override int get columnSpan => 12;

  @override
  Widget build(BuildContext context) => const StatWidget(
    stats: [
      Stat(label: 'Penjualan hari ini', value: 'Rp 1,2jt',
           icon: Icons.payments, delta: 12.4),
      Stat(label: 'Order baru', value: '48',
           icon: Icons.shopping_cart, delta: -3.1),
      Stat(label: 'Pelanggan', value: '312',
           icon: Icons.people, description: '+12 minggu ini'),
    ],
  );
}
```

### ChartWidget — bar chart sederhana built-in

```dart
const ChartWidget(
  title: 'Penjualan mingguan',
  subtitle: '7 hari terakhir',
  data: [
    ChartPoint('Sen', 12), ChartPoint('Sel', 18),
    ChartPoint('Rab', 7),  ChartPoint('Kam', 24),
    ChartPoint('Jum', 16),
  ],
)
```

### TableDashboardWidget — embed tabel di dashboard

```dart
TableDashboardWidget<Order>(
  title: 'Order terbaru',
  schema: recentOrdersSchema,
  dataSource: OrderServices.dataSource,
  idOf: (r) => r.id,
)
```

`columnSpan` adalah grid 12 kolom — `6` = setengah lebar di desktop, `12` = full;
mobile di-collapse jadi full width. Untuk chart yang lebih kaya (fl_chart, dll),
subclass `DashboardWidget` langsung.

---

## FilamentPage (halaman kustom)

Halaman non-CRUD yang tetap ikut layout Panel (sidebar + topbar):

```dart
class PengaturanPage extends FilamentPage {
  const PengaturanPage();

  @override String   get slug  => 'pengaturan';
  @override String   get title => 'Pengaturan Sistem';
  @override IconData get icon  => Icons.settings;
  @override String?  get navigationGroup => 'Sistem';

  @override
  List<Widget> buildHeaderActions(BuildContext context) => [
    OutlinedButton(onPressed: () {}, child: const Text('Reset')),
    FilledButton(onPressed: () {}, child: const Text('Simpan')),
  ];

  @override
  Widget buildBody(BuildContext context) => const Text('Isi halaman...');
}
```

Daftar ke Panel di `pages: [const PengaturanPage()]`. Route otomatis jadi
`/<panel.path>/pengaturan`.

---

## DataSource

`DataSource<T>` adalah interface backend. Implementasikan sesuai stack-mu:

```dart
abstract class DataSource<T> {
  Future<PaginatedResult<T>> list(ListQuery query);
  Future<T?>     get(String id);
  Future<T>      create(Map<String, dynamic> data);
  Future<T>      update(String id, Map<String, dynamic> data);
  Future<void>   delete(String id);
  Stream<List<T>>? watch(ListQuery query) => null;  // opsional (live)
}
```

### MemoryDataSource — built-in untuk prototyping & test

```dart
final ds = MemoryDataSource<Produk>(
  idOf: (p) => p.id,
  toMap: (p) => p.toJson(),
  fromMap: Produk.fromJson,
  seed: [Produk(id: '1', nama: 'Kopi', harga: 15000, aktif: true)],
);
```

### Contoh impl Firestore

```dart
class FirestoreProdukDataSource extends DataSource<Produk> {
  final _col = FirebaseFirestore.instance.collection('produk');

  @override
  Future<PaginatedResult<Produk>> list(ListQuery query) async {
    Query<Map<String, dynamic>> q = _col;
    if (query.sortBy != null) {
      q = q.orderBy(query.sortBy!, descending: query.sortDesc);
    }
    final start = (query.page - 1) * query.perPage;
    final snap = await q.limit(query.perPage + start).get();
    final rows = snap.docs
        .skip(start)
        .map((d) => Produk.fromJson({...d.data(), 'id': d.id}))
        .toList();
    return PaginatedResult(
      data: rows, total: snap.size,
      page: query.page, perPage: query.perPage,
    );
  }

  @override
  Future<Produk?> get(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? Produk.fromJson({...s.data()!, 'id': s.id}) : null;
  }

  @override
  Future<Produk> create(Map<String, dynamic> data) async {
    final doc = await _col.add(data);
    return Produk.fromJson({...data, 'id': doc.id});
  }

  @override
  Future<Produk> update(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
    return (await get(id))!;
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
```

---

## Theme

```dart
const FilamentTheme(
  colors: FilamentColors.amber,   // .blue .emerald .rose .indigo .slate
  brightness: Brightness.light,    // .dark
  borderRadius: 8,
  fontFamily: 'Inter',             // opsional
)
```

Kustom palette penuh:

```dart
FilamentTheme(
  colors: FilamentColors(
    primary: Color(0xFF6366F1),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger:  Color(0xFFEF4444),
    info:    Color(0xFF3B82F6),
    gray:    Color(0xFF6B7280),
  ),
)
```

Akses tema di widget sendiri via `FilamentThemeScope.of(context)`:

```dart
final theme = FilamentThemeScope.of(context);
Container(color: theme.surface, ...);
```

---

## Mason bricks (CLI scaffolding)

Repo ini menyertakan 4 [Mason](https://pub.dev/packages/mason) brick untuk
men-generate boilerplate tanpa copy-paste:

```bash
# sekali di root project
mason get

# Generate model class
mason make model --name Produk \
  --fields "nama:String, harga:int, aktif:bool, createdAt:DateTime"

# Generate Resource lengkap + 4 halaman, auto-register ke panel_config.dart
mason make resource \
  --name Produk --label "Produk" --pluralLabel "Produk" \
  --icon inventory_2 --group "Master Data" \
  --fields "nama:String, harga:int, aktif:bool"

# Generate FilamentPage standalone
mason make page --name Pengaturan --title "Pengaturan Sistem" --icon settings

# Generate DashboardWidget (type: stat/chart/custom)
mason make widget --name TotalProduk --type stat --columnSpan 4
```

Brick `resource`, `page`, `widget` punya `post_gen` hook yang otomatis
menambahkan import + registrasi ke `lib/core/filament/panel_config.dart`
di antara marker:

```dart
// filament:imports
// filament:resources-begin ... // filament:resources-end
// filament:pages-begin     ... // filament:pages-end
// filament:widgets-begin   ... // filament:widgets-end
```

> **Jangan hapus marker** — hook mengandalkannya untuk auto-register.

Lihat [`bricks/*/README.md`](https://github.com/lamkhil/flutter_filament/tree/main/bricks)
untuk detail tiap brick.

---

## Contributing

Kontribusi sangat welcome! Untuk melaporkan bug atau mengusulkan fitur:

- **Issues**: <https://github.com/lamkhil/flutter_filament/issues>
- **Pull Requests**: <https://github.com/lamkhil/flutter_filament/pulls>

Untuk development lokal:

```bash
git clone https://github.com/lamkhil/flutter_filament.git
cd flutter_filament
flutter pub get
flutter analyze
flutter test
```

## Lisensi

[MIT](LICENSE) — bebas dipakai, dimodifikasi, didistribusikan.
