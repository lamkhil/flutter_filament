import 'form_component.dart';
import 'form_state.dart';

/// Declarative container holding the list of [FormComponent]s for a form.
/// Filament equivalent: `Filament\Forms\Form::schema([...])`.
class FormSchema {
  final List<FormComponent> components;
  final int columns;

  const FormSchema({
    required this.components,
    this.columns = 1,
  });

  FormSchema copyWith({List<FormComponent>? components, int? columns}) =>
      FormSchema(
        components: components ?? this.components,
        columns: columns ?? this.columns,
      );

  /// Recursively collect every named field in render order.
  List<Field> get fields {
    final out = <Field>[];
    void walk(Iterable<FormComponent> list) {
      for (final c in list) {
        if (c is Field) out.add(c);
        final children = _childrenOf(c);
        if (children.isNotEmpty) walk(children);
      }
    }
    walk(components);
    return out;
  }

  /// Validate the whole schema against current state.
  /// Populates [FormStateController.errors] and returns `true` if valid.
  bool validate(FormStateController state) {
    state.clearErrors();
    var ok = true;
    for (final field in fields) {
      final err = field.validate(state);
      if (err != null) {
        state.setError(field.name, err);
        ok = false;
      }
    }
    return ok;
  }

  /// Apply default values from fields into [state] for keys that are missing.
  void applyDefaults(FormStateController state) {
    final patch = <String, dynamic>{};
    for (final field in fields) {
      if (!state.values.containsKey(field.name) &&
          field.defaultValue != null) {
        patch[field.name] = field.defaultValue;
      }
    }
    if (patch.isNotEmpty) state.setAll(patch);
  }

  /// Returns only the values defined by this schema (filters extraneous keys).
  Map<String, dynamic> extractValues(FormStateController state) {
    final out = <String, dynamic>{};
    for (final field in fields) {
      if (state.values.containsKey(field.name)) {
        out[field.name] = state.get(field.name);
      }
    }
    return out;
  }

  /// Hook for layout containers to expose children (Section/Grid override).
  static List<FormComponent> _childrenOf(FormComponent c) {
    if (c is FormLayoutComponent) return c.children;
    return const [];
  }
}

/// Marker base for layout-only components (Section, Grid) that hold children.
abstract class FormLayoutComponent extends FormComponent {
  List<FormComponent> get children;

  @override
  String? get name => null;
}
