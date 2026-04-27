## 0.1.0

- Initial release.
- `Panel` with auto-built sidebar navigation from resources + custom pages.
- `Resource<T>` with four default pages (list, create, edit, view) wired
  into `GoRouter` via `Resource.buildRoute()`.
- `FormSchema` builder with components: `TextInput`, `Textarea`, `Select`,
  `Toggle`, `CheckboxInput`, `DatePickerInput`, `NumberInput`, `Section`,
  `Grid`. Reactive `visibleWhen` + custom `rules`.
- `TableSchema<T>` with columns: `TextColumn`, `BadgeColumn`, `DateColumn`,
  `IconColumn`, `BooleanColumn`. Built-in search, sort, pagination,
  per-page selector, filters, `RowAction`, `HeaderAction`, `BulkAction`
  (with confirmation dialogs).
- Dashboard widgets: `StatWidget`, `ChartWidget` (simple built-in bar
  chart), `TableDashboardWidget`. 12-column responsive grid via
  `columnSpan`.
- `DataSource<T>` abstract interface + `MemoryDataSource<T>` reference
  implementation.
- Mason bricks: `model`, `resource`, `page`, `widget` with `post_gen`
  hooks for auto-registration into `panel_config.dart`.

## 0.1.1
- Fix null pointer di parser

## 0.2.3

- Public `ErrorView` widget (di `flutter_filament` exports). Pakai dari
  `StreamBuilder` / `FutureBuilder` / page custom mana saja yang punya
  error state — jadi UX error konsisten di seluruh app, tidak terbatas
  ke `TableBuilderWidget`. Props: `error`, `onRetry?`, `message?`,
  `padding?`, `maxWidth?`. Public statics: `ErrorView.extractUrls(text)`
  + `ErrorView.linkLabel(url)`.
- Error state sekarang:
  - Pesan error pakai `SelectableText` (admin bisa copy stack trace).
  - URL di pesan di-extract via regex dan di-render jadi tombol
    "Buka link" (label "Buka link untuk buat index" kalau URL terdeteksi
    sebagai index console — `/indexes` atau `create_composite=`).
    Tombol pakai `url_launcher` dengan `LaunchMode.externalApplication` —
    di web buka tab baru, di mobile buka browser eksternal.
  - Tombol "Coba lagi" otomatis muncul kalau `onRetry` di-pass.
- `TableBuilderWidget` error state di-refactor pakai `ErrorView` (tidak
  ada perubahan visual buat caller).
- `ErrorView` otomatis `developer.log` setiap error masuk (sekali per
  identitas error, tidak spam di rebuild). Index URL juga di-`print`
  terpisah dengan tag `[firestore.index]` supaya gampang di-grep di
  browser console / `flutter run` log.
- Public statics:
  - `ErrorView.isIndexUrl(url)` — true kalau URL match `/indexes` atau
    `create_composite=`.
  - `ErrorView.linkLabel(url)` — label otomatis "Buka link untuk buat
    index" / "Buka link".
  - `ErrorView.report(error, {message?})` — log error tanpa render UI.
    Pakai dari catch block / flow yang tidak punya widget tree, supaya
    error tetap masuk ke `developer.log` dengan tag yang tepat.
  - `ErrorView.showAsSnackBar(context, error, {message?, duration?})` —
    tampilkan SnackBar + auto log + action "Buka link" kalau pesan error
    mengandung URL (utamanya index URL Firestore).
- Dependency baru: `url_launcher: ^6.3.1`.

## 0.2.2

- `DataSource<T>` punya `Listenable get onChange` + helper `notifyChanged()`.
  `MemoryDataSource` sudah memanggilnya pada `create` / `update` / `delete`;
  custom implementation perlu memanggil `notifyChanged()` setelah mutasi
  agar table refresh otomatis.
- `TableBuilderWidget` subscribe ke `dataSource.onChange` dan re-fetch
  otomatis ketika data source ber-mutasi. Memperbaiki kasus list page
  yang stale setelah edit/create/delete kembali via `context.go(...)`
  (GoRouter sering mempertahankan instance list page sehingga `initState`
  tidak ter-trigger lagi).
- Additive — tidak ada breaking change.

## 0.2.1

- `ResourcePage.list/create/view/edit` factory sekarang menerima parameter
  opsional `builder` (dan `path`) sehingga user bisa membungkus default
  page dengan widget kustom-nya sendiri tanpa kehilangan `kind` (yang
  dipakai framework untuk men-derive header action "Create" di list page,
  dll). Pola pakai ala Filament:

  ```dart
  // user/pages/list_users.dart
  class ListUsers extends StatelessWidget {
    final Resource<AppUser> resource;
    const ListUsers({super.key, required this.resource});

    static ResourcePage<AppUser> route() => ResourcePage.list<AppUser>(
          builder: (ctx, state, r) => ListUsers(resource: r),
        );

    @override
    Widget build(BuildContext context) =>
        ListRecordsPage<AppUser>(resource: resource);
  }

  // user_resource.dart
  @override
  Map<String, ResourcePage<AppUser>> pages() => {
        'index': ListUsers.route(),
        'create': CreateUser.route(),
        'view': ViewUser.route(),
        'edit': EditUser.route(),
      };
  ```

  Setara `'index' => Pages\ListUsers::route('/')` di FilamentPHP. User
  bisa nanti meng-override `build()` page-nya untuk custom header action,
  tab tambahan, dst.

## 0.2.0

**Breaking changes**

- `Resource.pages()` sekarang mengembalikan `Map<String, ResourcePage<T>>`
  (sebelumnya `List<ResourcePageDef>`). Key map menjadi nama page seperti
  di Filament 5 (`'index'`, `'create'`, `'view'`, `'edit'`).
- Class `ResourcePageDef` & enum `DefaultPageKind` dihapus, diganti
  `ResourcePage` & `ResourcePageKind`. Factory tetap konsisten:
  `ResourcePage.list()`, `.create()`, `.view()`, `.edit()`,
  `.custom(path: ..., builder: ...)`.
- Custom page builder sekarang menerima `Resource<T>` sebagai argumen
  ketiga: `(BuildContext, GoRouterState, Resource<T>) → Widget`.
  Sebelumnya hanya 2 argumen pertama.

**New**

- `RelationManager<TParent, TChild>` — manajer relasi ala
  Filament. Override `title`, `table(parent)`, `dataSource(parent)`,
  `childId(record)`. Daftarkan via `Resource.relations()` dan akan
  ter-render sebagai tabs di edit/view page.
- `RelationTabs` widget di-expose kalau perlu render relasi di tempat
  kustom.
- `Resource.hasEditPage` / `hasViewPage` getter konvenience untuk cek
  page mana saja yang aktif (dipakai internal, juga berguna di custom
  layout).

**Migration guide**

```dart
// Before (0.1.x):
@override
List<ResourcePageDef> pages() => [
  ResourcePageDef.list(),
  ResourcePageDef.create(),
  ResourcePageDef.edit(),
];

// After (0.2.0):
@override
Map<String, ResourcePage<MyModel>> pages() => {
  'index': ResourcePage.list<MyModel>(),
  'create': ResourcePage.create<MyModel>(),
  'edit': ResourcePage.edit<MyModel>(),
};
```

```dart
// Custom page builder argument signature changed:
// Before:
ResourcePageDef.custom(
  path: 'reports',
  name: 'reports',
  builder: (ctx, state) => ReportsPage(),
);

// After:
ResourcePage.custom<MyModel>(
  path: 'reports',
  builder: (ctx, state, resource) => ReportsPage(resource: resource),
);
```
