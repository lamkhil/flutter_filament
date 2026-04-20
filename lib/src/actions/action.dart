import 'package:flutter/material.dart';

/// Semantic color class for an action's visual treatment.
enum ActionColor { primary, success, warning, danger, info, gray }

/// Base class shared by header/row/bulk actions.
/// Filament equivalent: `Filament\Actions\Action`.
abstract class FilamentAction {
  final String name;
  final String label;
  final IconData? icon;
  final ActionColor color;
  final bool requiresConfirmation;
  final String? confirmationTitle;
  final String? confirmationMessage;

  const FilamentAction({
    required this.name,
    required this.label,
    this.icon,
    this.color = ActionColor.primary,
    this.requiresConfirmation = false,
    this.confirmationTitle,
    this.confirmationMessage,
  });
}
