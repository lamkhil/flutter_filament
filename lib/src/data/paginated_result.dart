/// Result of a paginated list query.
class PaginatedResult<T> {
  final List<T> data;
  final int total;
  final int page;
  final int perPage;

  const PaginatedResult({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
  });

  int get totalPages => perPage == 0 ? 1 : (total / perPage).ceil();
  bool get hasNext => page < totalPages;
  bool get hasPrev => page > 1;

  factory PaginatedResult.empty() =>
      PaginatedResult(data: const [], total: 0, page: 1, perPage: 10);
}

/// Query descriptor passed to [DataSource.list].
class ListQuery {
  final int page;
  final int perPage;
  final String? search;
  final Map<String, dynamic> filters;
  final String? sortBy;
  final bool sortDesc;

  const ListQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.filters = const {},
    this.sortBy,
    this.sortDesc = false,
  });

  ListQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool? sortDesc,
  }) =>
      ListQuery(
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        search: search ?? this.search,
        filters: filters ?? this.filters,
        sortBy: sortBy ?? this.sortBy,
        sortDesc: sortDesc ?? this.sortDesc,
      );
}
