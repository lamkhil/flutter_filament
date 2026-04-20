import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';

/// On/off switch. Filament: `Toggle::make('aktif')`.
class Toggle extends Field {
  Toggle({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                  ),
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
          Switch(
            value: value,
            onChanged: disabled ? null : (v) => state.set(name, v),
            activeThumbColor: theme.colors.primary,
          ),
        ],
      ),
    );
  }
}
