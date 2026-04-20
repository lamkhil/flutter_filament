import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';
import 'text_input.dart';

/// Daftar checkbox multi-select yang menghasilkan `List<T>` di form state.
/// Filament: `CheckboxList::make('roles')->options([...])`.
class CheckboxList<T> extends Field {
  final List<CheckboxListOption<T>> options;
  final int columns;

  CheckboxList({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.defaultValue,
    super.required,
    super.disabled,
    super.rules,
    super.visibleWhen,
    super.columnSpan,
    this.columns = 1,
  });

  @override
  String? validate(FormStateController state) {
    if (!isVisible(state)) return null;
    final v = state.get(name);
    if (this.required && (v == null || (v is List && v.isEmpty))) {
      return '$label wajib diisi';
    }
    for (final rule in rules) {
      final err = rule(v, state);
      if (err != null) return err;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    final selected = (state.get<List>(name) ?? const []).toList();

    void toggle(T value) {
      final list = List<T>.from(selected.cast<T>());
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
      state.set(name, list);
    }

    return LabeledField(
      label: label,
      isRequired: this.required,
      helperText: helperText,
      error: state.errorOf(name),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        child: LayoutBuilder(
          builder: (ctx, c) {
            final cols = columns.clamp(1, 4);
            final gap = 8.0;
            final itemW = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: 4,
              children: options.map((o) {
                final checked = selected.contains(o.value);
                return SizedBox(
                  width: itemW,
                  child: InkWell(
                    onTap: disabled ? null : () => toggle(o.value),
                    borderRadius:
                        BorderRadius.circular(theme.borderRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Checkbox(
                            value: checked,
                            onChanged: disabled
                                ? null
                                : (_) => toggle(o.value),
                            activeColor: theme.colors.primary,
                          ),
                          Expanded(
                            child: Text(
                              o.label,
                              style: TextStyle(color: theme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class CheckboxListOption<T> {
  final T value;
  final String label;
  const CheckboxListOption(this.value, this.label);
}
