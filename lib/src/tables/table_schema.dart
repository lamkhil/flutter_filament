import '../actions/bulk_action.dart';
import '../actions/header_action.dart';
import '../actions/row_action.dart';
import 'table_column.dart';
import 'table_filter.dart';

/// Declarative table definition.
/// Filament equivalent: `Filament\Tables\Table::schema([...])`.
class TableSchema<T> {
  final List<TableColumn<T>> columns;
  final List<TableFilter> filters;
  final List<RowAction<T>> rowActions;
  final List<HeaderAction> headerActions;
  final List<BulkAction<T>> bulkActions;
  final bool searchable;
  final bool paginated;
  final int defaultPerPage;
  final List<int> perPageOptions;
  final String? defaultSort;
  final bool defaultSortDesc;
  final String? emptyTitle;
  final String? emptyDescription;
  final String? searchPlaceholder;

  const TableSchema({
    required this.columns,
    this.filters = const [],
    this.rowActions = const [],
    this.headerActions = const [],
    this.bulkActions = const [],
    this.searchable = true,
    this.paginated = true,
    this.defaultPerPage = 10,
    this.perPageOptions = const [10, 25, 50, 100],
    this.defaultSort,
    this.defaultSortDesc = false,
    this.emptyTitle,
    this.emptyDescription,
    this.searchPlaceholder,
  });
}
