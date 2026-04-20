import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';

/// Boolean checkbox. Filament: `Checkbox::make('setuju')`.
class CheckboxInput extends Field {
  CheckboxInput({
    required super.name,
    required super.label,
    super.helperText,
    super.defaultValue = false,
    super.disabled,
    super.visibleWhen,
    super.columnSpan,
  });

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    final value = state.get<bool>(name) ?? false;
    return InkWell(
      onTap: disabled ? null : () => state.set(name, !value),
      borderRadius: BorderRadius.circular(theme.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: disabled ? null : (v) => state.set(name, v ?? false),
              activeColor: theme.colors.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: theme.textPrimary),
                  ),
                  if (helperText != null)
                    Text(
                      helperText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
