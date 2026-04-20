/// Context passed to `Resource.form()` so the schema can vary by page
/// (create vs edit) or by currently-edited record.
enum ResourceOperation { create, edit, view }

class ResourceContext<T> {
  final ResourceOperation operation;
  final T? record;

  const ResourceContext({required this.operation, this.record});

  bool get isCreate => operation == ResourceOperation.create;
  bool get isEdit => operation == ResourceOperation.edit;
  bool get isView => operation == ResourceOperation.view;
}
