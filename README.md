# flutter_filament

Framework admin panel untuk Flutter yang terinspirasi [Filament 5](https://filamentphp.com/). Bangun panel admin lengkap dengan **Panel**, **Resource**, **Form schema**, **Table schema**, dan **Dashboard widget** — semua schema-driven, tanpa perlu menulis UI CRUD manual.

- **Panel** sebagai pondasi (mirip Filament `Panel`)
- **Resource\<T\>** otomatis men-generate 4 halaman: list, create, edit, view
- **FormSchema** builder dengan komponen reaktif (TextInput, Select, Toggle, DatePicker, dst.)
- **TableSchema** dengan search/sort/filter/pagination, row actions, header actions, bulk actions
- **DataSource\<T\>** abstrak — backend bebas (Firestore, REST, GraphQL, in-memory)
- **Mason bricks** untuk scaffolding model/resource/page/widget dari CLI

---

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
13. [Publish ke pub.dev](#publish-ke-pubdev)

---

## Instalasi

Tambahkan di `pubspec.yaml`:

```yaml
dependencies:
  flutter_filament: ^0.1.0
```

atau pakai versi lokal (monorepo):

```yaml
dependencies:
  flutter_filament:
    path: packages/flutter_filament
```

Lalu:

```bash
flutter pub get
```

---

## Quick start

```dart
// lib/main.dart
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

Jalankan aplikasi dan buka `/admin`. Sidebar otomatis terbentuk dari daftar `resources` dan `widgets`.

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
| `ListRecords`, `CreateRecord`, `EditRecord`, `ViewRecord` | otomatis — dibuat oleh `Resource.buildRoute()` |
| `Page::class` (standalone) | `class FooPage extends FilamentPage` |

---

## Panel

`Panel` adalah top-level container. Satu aplikasi bisa punya banyak panel (misal `admin` dan `app`), masing-masing dengan path, theme, dan resource sendiri.

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
  resources: [
    ProdukResource(),
    UserResource(),
  ],
  pages: const [
    PengaturanPage(),
  ],
  widgets: const [
    TotalPenjualanWidget(),
    GrafikMingguanWidget(),
  ],
  // override layout sidebar jika perlu; null = auto dari resources+pages
  navigationOverride: null,
  // widget di bawah sidebar (misal tombol logout)
  sidebarFooter: const SidebarFooter(),
);

// Daftarkan route Panel ke GoRouter:
final router = GoRouter(routes: [
  ...adminPanel.buildRoutes(),
  // ...route lain
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

`Resource<T>` mengikat sebuah model ke Panel: menyediakan data source, schema form, schema table, dan 4 halaman default.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'models/produk.dart';

class ProdukResource extends Resource<Produk> {
  @override String get slug => 'produk';
  @override String get label => 'Produk';
  @override String get pluralLabel => 'Produk';
  @override IconData get icon => Icons.inventory_2;
  @override String? get navigationGroup => 'Master Data';
  @override int get navigationSort => 10;

  @override
  DataSource<Produk> get dataSource => ProdukServices.dataSource;

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
      Section(
        title: 'Informasi Produk',
        icon: Icons.info_outline,
        columns: 2,
        children: [
          TextInput(name: 'nama', label: 'Nama', required: true, columnSpan: 2),
          NumberInput(name: 'harga', label: 'Harga', prefix: 'Rp', required: true),
          Select<String>(
            name: 'kategori',
            label: 'Kategori',
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
        name: 'kategori',
        label: 'Kategori',
        options: const [
          TableFilterOption('makanan', 'Makanan'),
          TableFilterOption('minuman', 'Minuman'),
        ],
      ),
    ],
    rowActions: [
      RowAction.view<Produk>((ctx, row) async { /* handled by list page */ }),
      RowAction.edit<Produk>((ctx, row) async { /* handled by list page */ }),
      RowAction.delete<Produk>((ctx, row) async {
        await ProdukServices.dataSource.delete(row.id);
      }),
    ],
    headerActions: [
      HeaderAction(
        name: 'export',
        label: 'Ekspor CSV',
        icon: Icons.download,
        onPressed: (ctx) async { /* ... */ },
      ),
    ],
  );
}
```

`ResourceContext<T>` berisi `operation` (`create`/`edit`/`view`) dan `record` saat ini, sehingga schema bisa bercabang:

```dart
FormSchema form(ResourceContext<Produk> ctx) => FormSchema(
  components: [
    TextInput(name: 'nama', label: 'Nama', required: true),
    if (ctx.isEdit)
      TextInput(name: 'id', label: 'ID', disabled: true),
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
  // view dihilangkan
  ResourcePageDef.custom(
    path: 'laporan',
    name: 'laporan',
    builder: (ctx, state) => const ProdukLaporanPage(),
  ),
];
```

---

## FormSchema + komponen

Daftar komponen built-in:

| Komponen | Kegunaan | Filament setara |
|---|---|---|
| `TextInput` | Text satu baris | `TextInput::make()` |
| `Textarea` | Text multi-baris | `Textarea::make()` |
| `NumberInput` | Angka (int/double) dengan min/max/prefix/suffix | `TextInput::make()->numeric()` |
| `Select<T>` | Dropdown single-select | `Select::make()` |
| `Toggle` | Switch on/off | `Toggle::make()` |
| `CheckboxInput` | Checkbox | `Checkbox::make()` |
| `DatePickerInput` | Tanggal / jam / tanggal+jam | `DatePicker::make()` / `TimePicker` |
| `Section` | Card bertitle + children (bisa collapsible) | `Section::make()` |
| `Grid` | Layout N kolom untuk anak-anaknya | `Grid::make(n)` |

**Validasi & reaktivitas**:

```dart
TextInput(
  name: 'email',
  label: 'Email',
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

`visibleWhen` dan `rules` menerima `FormStateController` jadi kamu bisa akses nilai field lain — ini mirip Filament `$get('field')`.

**Render form manual** (di luar resource):

```dart
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _state = FormStateController();
  final _schema = FormSchema(components: [
    TextInput(name: 'nama', label: 'Nama', required: true),
    NumberInput(name: 'umur', label: 'Umur'),
  ]);

  void _submit() {
    if (!_schema.validate(_state)) {
      setState(() {}); // tampilkan error
      return;
    }
    final values = _schema.extractValues(_state);
    print(values); // {nama: '...', umur: 25}
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    FormBuilderWidget(schema: _schema, state: _state),
    FilledButton(onPressed: _submit, child: const Text('Simpan')),
  ]);
}
```

---

## TableSchema + kolom + action

Daftar kolom:

| Kolom | Kegunaan |
|---|---|
| `TextColumn<T>` | Text biasa, bisa formatter |
| `BadgeColumn<T>` | Badge berwarna + icon opsional |
| `DateColumn<T>` | Tanggal dengan pattern `dd MMM yyyy` |
| `IconColumn<T>` | Icon driven by row |
| `BooleanColumn<T>` | ✓/✗ otomatis |

Setiap kolom bisa `searchable`, `sortable`, `align` (start/center/end), `width`, dan menyediakan `accessor: (row) => value` untuk mengekstrak data.

**Action types**:

```dart
// Row (per baris)
RowAction<Produk>(
  name: 'duplicate',
  label: 'Duplikat',
  icon: Icons.copy,
  color: ActionColor.info,
  requiresConfirmation: true,
  visibleWhen: (row) => row.aktif,
  onPressed: (ctx, row) async { /* ... */ },
)

// Header (atas tabel — biasanya "Create", "Export")
HeaderAction(
  name: 'create',
  label: 'Tambah Produk',
  icon: Icons.add,
  onPressed: (ctx) async { ctx.goNamed('produk.create'); },
)

// Bulk (aksi pada beberapa row terpilih)
BulkAction<Produk>(
  name: 'delete',
  label: 'Hapus',
  color: ActionColor.danger,
  requiresConfirmation: true,
  onPressed: (ctx, rows) async { /* ... */ },
)
```

Factory cepat untuk action standar:

```dart
RowAction.edit<Produk>((ctx, row) async { /* ... */ })
RowAction.view<Produk>((ctx, row) async { /* ... */ })
RowAction.delete<Produk>((ctx, row) async { /* ... */ })  // sudah include confirmation
```

**Render tabel manual** (di luar resource):

```dart
TableBuilderWidget<Produk>(
  schema: produkTableSchema,
  dataSource: ProdukServices.dataSource,
  idOf: (row) => row.id,
  onRowTap: (row) => /* ... */,
)
```

---

## Dashboard widget

**StatWidget** — baris statistik:

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

**ChartWidget** — bar chart sederhana built-in:

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

**TableDashboardWidget** — embed tabel di dashboard:

```dart
TableDashboardWidget<Order>(
  title: 'Order terbaru',
  schema: recentOrdersSchema,
  dataSource: OrderServices.dataSource,
  idOf: (r) => r.id,
)
```

**Custom widget** — subclass `DashboardWidget` langsung untuk apapun (misal chart dengan `fl_chart`, map, dll).

`columnSpan` adalah grid 12-kolom — `6` = setengah lebar di desktop, `12` = full; mobile di-collapse jadi full.

---

## FilamentPage (halaman kustom)

Untuk halaman non-CRUD yang tetap ikut layout Panel (sidebar + topbar):

```dart
class PengaturanPage extends FilamentPage {
  const PengaturanPage();

  @override String get slug => 'pengaturan';
  @override String get title => 'Pengaturan Sistem';
  @override IconData get icon => Icons.settings;
  @override String? get navigationGroup => 'Sistem';

  @override
  List<Widget> buildHeaderActions(BuildContext context) => [
    OutlinedButton(onPressed: () {}, child: const Text('Reset')),
    FilledButton(onPressed: () {}, child: const Text('Simpan')),
  ];

  @override
  Widget buildBody(BuildContext context) => const Text('Isi halaman...');
}
```

Daftar ke Panel di `pages: [const PengaturanPage()]`. Route otomatis jadi `/<panel.path>/pengaturan`.

---

## DataSource

`DataSource<T>` adalah interface backend. Implementasikan sesuai stack kamu:

```dart
abstract class DataSource<T> {
  Future<PaginatedResult<T>> list(ListQuery query);
  Future<T?> get(String id);
  Future<T> create(Map<String, dynamic> data);
  Future<T> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Stream<List<T>>? watch(ListQuery query) => null;  // opsional (live)
}
```

**`MemoryDataSource<T>`** — built-in untuk prototyping/test:

```dart
final ds = MemoryDataSource<Produk>(
  idOf: (p) => p.id,
  toMap: (p) => p.toJson(),
  fromMap: (m) => Produk.fromJson(m),
  seed: [
    Produk(id: '1', nama: 'Kopi', harga: 15000, aktif: true),
  ],
);
```

**Contoh impl Firestore**:

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
      data: rows, total: snap.size, page: query.page, perPage: query.perPage,
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
  colors: FilamentColors.amber,        // atau .blue, .emerald, .rose, .indigo, .slate
  brightness: Brightness.light,         // atau .dark
  borderRadius: 8,
  fontFamily: 'Inter',                  // opsional
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

Akses di widget kamu sendiri lewat `FilamentThemeScope.of(context)`:

```dart
final theme = FilamentThemeScope.of(context);
Container(color: theme.surface, ...);
```

---

## Mason bricks (CLI scaffolding)

Paket ini datang dengan 4 Mason brick untuk men-generate boilerplate:

```bash
# satu kali di root project
mason get

# generate model class
mason make model --name Produk --fields "nama:String, harga:int, aktif:bool, createdAt:DateTime"

# generate Resource lengkap + 4 halaman, auto-register ke panel_config.dart
mason make resource \
  --name Produk --label "Produk" --pluralLabel "Produk" \
  --icon inventory_2 --group "Master Data" \
  --fields "nama:String, harga:int, aktif:bool"

# generate FilamentPage standalone
mason make page --name Pengaturan --title "Pengaturan Sistem" --icon settings

# generate DashboardWidget (type: stat/chart/custom)
mason make widget --name TotalProduk --type stat --columnSpan 4
```

Setiap brick `resource`, `page`, `widget` punya `post_gen` hook yang menambahkan import + registrasi ke `lib/core/filament/panel_config.dart` di antara marker:

```dart
// filament:imports
// filament:resources-begin ... // filament:resources-end
// filament:pages-begin     ... // filament:pages-end
// filament:widgets-begin   ... // filament:widgets-end
```

**Jangan hapus marker** — hook mengandalkannya untuk auto-register. Setelah generate, edit file resource-nya untuk menyesuaikan form/table sesuai domain.

Lihat `bricks/*/README.md` untuk detail tiap brick.

---

## Publish ke pub.dev

Kalau mau rilis paket ini (atau fork-nya) ke [pub.dev](https://pub.dev):

### 1. Siapkan metadata

Edit `pubspec.yaml`, **hapus** baris `publish_to: 'none'` lalu lengkapi:

```yaml
name: flutter_filament
description: Filament 5-inspired admin panel framework for Flutter. Schema-driven forms, tables, resources with auto-generated CRUD pages.
version: 0.1.0
homepage: https://github.com/<user>/flutter_filament
repository: https://github.com/<user>/flutter_filament
issue_tracker: https://github.com/<user>/flutter_filament/issues
documentation: https://pub.dev/documentation/flutter_filament/latest/
topics:
  - admin
  - panel
  - crud
  - filament
  - scaffold
```

> pub.dev pakai `description` untuk pencarian — 60–180 karakter, imbangi keyword & kejelasan.

### 2. File wajib

- `README.md` — sudah ada
- `CHANGELOG.md` — catatan versi (wajib, pub.dev akan render)
- `LICENSE` — lisensi open-source (MIT/Apache-2.0/BSD umum)

Template `CHANGELOG.md`:

```md
## 0.1.0

- Initial release.
- Panel + Resource + 4 default pages (list/create/edit/view).
- FormSchema with TextInput, Textarea, Select, Toggle, Checkbox, DatePicker,
  NumberInput, Section, Grid.
- TableSchema with TextColumn, BadgeColumn, DateColumn, IconColumn,
  BooleanColumn + search/sort/filter/pagination.
- Dashboard widgets: StatWidget, ChartWidget, TableDashboardWidget.
- DataSource abstraction + MemoryDataSource impl.
- Mason bricks: model, resource, page, widget.
```

### 3. Example app

pub.dev memberi poin ekstra kalau ada `example/`:

```
packages/flutter_filament/
├── example/
│   ├── pubspec.yaml
│   ├── lib/
│   │   └── main.dart        # minimal app pakai flutter_filament
│   └── README.md
```

### 4. Validasi sebelum publish

```bash
cd packages/flutter_filament

# analyze harus 0 issue
flutter analyze

# format
dart format --set-exit-if-changed .

# dry-run: pub.dev akan cek pubspec, LICENSE, README, dan kalkulasi pub score
dart pub publish --dry-run
```

Outputnya menampilkan daftar file yang akan di-upload + warning. Perbaiki sampai bersih.

### 5. Login & publish

```bash
# pertama kali: login pakai akun Google
dart pub login

# publish (akan minta konfirmasi y/N)
dart pub publish
```

pub.dev akan meng-upload paket, men-generate dokumentasi dari docstring, dan menghitung [pub score](https://pub.dev/help/scoring):
- ✓ follows Dart file conventions (pubspec, README, CHANGELOG, LICENSE)
- ✓ provides documentation (dartdoc `///`)
- ✓ platform support (Android/iOS/web/desktop — Flutter multi-platform otomatis)
- ✓ passes static analysis
- ✓ supports up-to-date dependencies

### 6. Versioning

Patuh [semver](https://semver.org):
- `0.1.0 → 0.1.1` — bugfix
- `0.1.0 → 0.2.0` — fitur baru, breaking change boleh (pre-1.0)
- `0.x → 1.0.0` — API stabil, breaking harus di mayor bump setelahnya

Setiap rilis: bump `version:` di pubspec + tulis catatan di CHANGELOG + `dart pub publish`.

### 7. Verified publisher (opsional)

Untuk badge ✓ di pub.dev, daftarkan domain di [pub.dev/publishers](https://pub.dev/publishers/create) dan tambahkan `publish_to` ke pubspec. Butuh domain aktif + DNS TXT record.

---

## Lisensi

MIT — bebas dipakai, dimodifikasi, didistribusikan. Lihat [LICENSE](LICENSE).
