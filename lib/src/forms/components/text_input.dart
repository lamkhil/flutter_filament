import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';

/// Single-line text input. Filament: `TextInput::make('name')`.
class TextInput extends Field {
  final TextInputType keyboardType;
  final bool obscure;
  final int? maxLength;
  final IconData? prefixIcon;

  TextInput({
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
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.maxLength,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    final error = state.errorOf(name);
    return _LabeledField(
      label: label,
      isRequired: this.required,
      helperText: helperText,
      error: error,
      child: TextFormField(
        initialValue: state.get<String>(name) ?? '',
        enabled: !disabled,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: (v) => state.set(name, v),
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
            borderSide: BorderSide(color: theme.border),
          ),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
      ),
    );
  }
}

/// Shared label + helper/error row used by all form fields.
class _LabeledField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final String? error;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.isRequired,
    required this.child,
    this.helperText,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colors.danger),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error!,
              style: TextStyle(
                color: theme.colors.danger,
                fontSize: 12,
              ),
            ),
          )
        else if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helperText!,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

/// Exported for reuse by sibling components.
class LabeledField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final String? error;
  final Widget child;

  const LabeledField({
    super.key,
    required this.label,
    required this.isRequired,
    required this.child,
    this.helperText,
    this.error,
  });

  @override
  Widget build(BuildContext context) => _LabeledField(
        label: label,
        isRequired: isRequired,
        helperText: helperText,
        error: error,
        child: child,
      );
}
