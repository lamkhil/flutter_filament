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
