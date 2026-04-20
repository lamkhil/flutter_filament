import 'package:flutter/widgets.dart';
import 'form_state.dart';

typedef FormValidator = String? Function(dynamic value, FormStateController state);
typedef FormVisibility = bool Function(FormStateController state);

/// Base class for every form element (field, section, grid, etc).
/// Filament equivalent: `Filament\Forms\Components\Component`.
abstract class FormComponent {
  /// Key used in the form values map. Layout-only components may leave null.
  String? get name;

  /// Render this component.
  Widget build(BuildContext context, FormStateController state);

  /// Run validation. Default: no-op.
  String? validate(FormStateController state) => null;
}

/// Common concerns for components that carry a single value (fields).
/// Named [Field] to mirror Filament's base class and avoid collision with
/// Flutter's `FormField` widget.
abstract class Field extends FormComponent {
  @override
  final String name;
  final String label;
  final String? helperText;
  final String? placeholder;
  final dynamic defaultValue;
  final bool required;
  final bool disabled;
  final List<FormValidator> rules;
  final FormVisibility? visibleWhen;
  final int columnSpan;

  Field({
    required this.name,
    required this.label,
    this.helperText,
    this.placeholder,
    this.defaultValue,
    this.required = false,
    this.disabled = false,
    this.rules = const [],
    this.visibleWhen,
    this.columnSpan = 1,
  });

  bool isVisible(FormStateController state) =>
      visibleWhen?.call(state) ?? true;

  @override
  String? validate(FormStateController state) {
    if (!isVisible(state)) return null;
    final value = state.get(name);
    if (required) {
      final empty = value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is Iterable && value.isEmpty);
      if (empty) return '$label wajib diisi';
    }
    for (final rule in rules) {
      final err = rule(value, state);
      if (err != null) return err;
    }
    return null;
  }
}
