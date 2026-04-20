import 'package:flutter/material.dart';
import 'action.dart';

typedef HeaderActionHandler = Future<void> Function(BuildContext context);

/// Top-of-table action (e.g. "Create new"). Filament: `HeaderAction`.
class HeaderAction extends FilamentAction {
  final HeaderActionHandler onPressed;

  const HeaderAction({
    required super.name,
    required super.label,
    required this.onPressed,
    super.icon,
    super.color,
    super.requiresConfirmation,
    super.confirmationTitle,
    super.confirmationMessage,
  });
}
