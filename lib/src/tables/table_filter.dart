/// Declarative filter that appears in the table toolbar.
/// Filament: `Tables\Filters\SelectFilter::make('status')`.
class TableFilter {
  final String name;
  final String label;
  final List<TableFilterOption> options;
  final bool multiple;

  const TableFilter({
    required this.name,
    required this.label,
    required this.options,
    this.multiple = false,
  });
}

class TableFilterOption {
  final dynamic value;
  final String label;
  const TableFilterOption(this.value, this.label);
}
