import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';
import 'text_input.dart';

/// Multi-line text input. Filament: `Textarea::make('description')`.
class Textarea extends Field {
  final int rows;
  final int? maxLength;

  Textarea({
    required super.name,
    required super.label,
    super.helperText,
    super.placeholder,
    super.defaultValue,
    super.required,
    super.disabled,
    super.rules,
    super.visibleWhen,
    super.columnSpan,
    this.rows = 4,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    return LabeledField(
      label: label,
      isRequired: this.required,
      helperText: helperText,
      error: state.errorOf(name),
      child: TextFormField(
        initialValue: state.get<String>(name) ?? '',
        enabled: !disabled,
        maxLines: rows,
        maxLength: maxLength,
        onChanged: (v) => state.set(name, v),
        decoration: InputDecoration(
          hintText: placeholder,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
            borderSide: BorderSide(color: theme.border),
          ),
        ),
      ),
    );
  }
}
