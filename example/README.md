# flutter_filament example

Minimal Flutter app demonstrating `flutter_filament`:

- a **Panel** mounted at `/admin`
- one **Resource** (`Produk`) backed by `MemoryDataSource`
- one dashboard **StatWidget**
- all four default pages (list, create, edit, view) auto-wired

## Run

```bash
cd packages/flutter_filament/example
flutter pub get
flutter run
```

Open <http://localhost:xxxxx/admin>.

## What to explore

- Sidebar auto-builds from `panel.resources` and `panel.widgets`.
- Click "Tambah Produk" — form uses the declarative `FormSchema`.
- Table supports search, sort, and row delete action.
- Dashboard stat tiles show percentage delta badges.

See `../README.md` for the full API.
