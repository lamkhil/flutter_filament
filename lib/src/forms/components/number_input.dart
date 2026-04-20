import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';
import 'text_input.dart';

/// Numeric input (int or double). Filament: `TextInput::make('x')->numeric()`.
class NumberInput extends Field {
  final bool allowDecimal;
  final num? min;
  final num? max;
  final String? suffix;
  final String? prefix;

  NumberInput({
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
    this.allowDecimal = false,
    this.min,
    this.max,
    this.suffix,
    this.prefix,
  });

  @override
  String? validate(FormStateController state) {
    final base = super.validate(state);
    if (base != null) return base;
    final v = state.get(name);
    if (v == null) return null;
    final num? n = v is num ? v : num.tryParse(v.toString());
    if (n == null) return '$label harus angka';
    if (min != null && n < min!) return '$label minimal $min';
    if (max != null && n > max!) return '$label maksimal $max';
    return null;
  }

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    final raw = state.get(name);
    final text = raw == null ? '' : raw.toString();
    return LabeledField(
      label: label,
      isRequired: this.required,
      helperText: helperText,
      error: state.errorOf(name),
      child: TextFormField(
        initialValue: text,
        enabled: !disabled,
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        inputFormatters: [
          if (allowDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))
          else
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
        ],
        onChanged: (v) {
          if (v.isEmpty) {
            state.set(name, null);
          } else {
            final parsed =
                allowDecimal ? double.tryParse(v) : int.tryParse(v);
            state.set(name, parsed ?? v);
          }
        },
        decoration: InputDecoration(
          hintText: placeholder,
          prefixText: prefix,
          suffixText: suffix,
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
