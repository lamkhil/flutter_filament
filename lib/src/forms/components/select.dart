import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';
import 'text_input.dart';

/// An option shown in a [Select].
class SelectOption<T> {
  final T value;
  final String label;
  const SelectOption(this.value, this.label);
}

/// Dropdown single-select. Filament: `Select::make('status')->options([...])`.
class Select<T> extends Field {
  final List<SelectOption<T>> options;
  final bool searchable;

  Select({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.placeholder,
    super.defaultValue,
    super.required,
    super.disabled,
    super.rules,
    super.visibleWhen,
    super.columnSpan,
    this.searchable = false,
  });

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    final current = state.get<T>(name);
    return LabeledField(
      label: label,
      isRequired: this.required,
      helperText: helperText,
      error: state.errorOf(name),
      child: DropdownButtonFormField<T>(
        initialValue: current,
        onChanged: disabled ? null : (v) => state.set(name, v),
        isExpanded: true,
        decoration: InputDecoration(
          hintText: placeholder ?? '-- pilih --',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
            borderSide: BorderSide(color: theme.border),
          ),
        ),
        items: options
            .map((o) => DropdownMenuItem<T>(
                  value: o.value,
                  child: Text(o.label),
                ))
            .toList(),
      ),
    );
  }
}
