import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_state.dart';
import 'text_input.dart';

enum DatePickerMode { date, time, datetime }

/// Date / time / datetime picker. Filament: `DatePicker::make('tanggal')`.
class DatePickerInput extends Field {
  final DatePickerMode mode;
  final DateTime? firstDate;
  final DateTime? lastDate;

  DatePickerInput({
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
    this.mode = DatePickerMode.date,
    this.firstDate,
    this.lastDate,
  });

  String _format(DateTime dt) {
    switch (mode) {
      case DatePickerMode.date:
        return DateFormat('dd MMM yyyy').format(dt);
      case DatePickerMode.time:
        return DateFormat('HH:mm').format(dt);
      case DatePickerMode.datetime:
        return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    }
  }

  @override
  Widget build(BuildContext context, FormStateController state) {
    if (!isVisible(state)) return const SizedBox.shrink();
    final theme = FilamentThemeScope.of(context);
    final current = state.get<DateTime>(name);
    final text = current != null ? _format(current) : (placeholder ?? '-- pilih --');
    return LabeledField(
      label: label,
      isRequired: this.required,
      helperText: helperText,
      error: state.errorOf(name),
      child: InkWell(
        onTap: disabled ? null : () => _pick(context, state, current),
        borderRadius: BorderRadius.circular(theme.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: theme.border),
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          child: Row(
            children: [
              Icon(
                mode == DatePickerMode.time
                    ? Icons.access_time
                    : Icons.calendar_today,
                size: 16,
                color: theme.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: current != null
                        ? theme.textPrimary
                        : theme.textMuted,
                  ),
                ),
              ),
              if (current != null && !disabled)
                InkWell(
                  onTap: () => state.set(name, null),
                  child: Icon(Icons.clear,
                      size: 16, color: theme.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    FormStateController state,
    DateTime? current,
  ) async {
    final now = DateTime.now();
    if (mode == DatePickerMode.time) {
      final picked = await showTimePicker(
        context: context,
        initialTime: current != null
            ? TimeOfDay.fromDateTime(current)
            : TimeOfDay.now(),
      );
      if (picked != null) {
        state.set(name,
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
      }
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: firstDate ?? DateTime(now.year - 50),
      lastDate: lastDate ?? DateTime(now.year + 50),
    );
    if (date == null) return;
    if (mode == DatePickerMode.date) {
      state.set(name, date);
      return;
    }
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.now(),
    );
    state.set(
      name,
      DateTime(date.year, date.month, date.day, time?.hour ?? 0,
          time?.minute ?? 0),
    );
  }
}
