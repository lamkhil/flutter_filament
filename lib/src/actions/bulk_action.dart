import 'package:flutter/material.dart';
import 'action.dart';

typedef BulkActionHandler<T> = Future<void> Function(
  BuildContext context,
  List<T> rows,
);

/// Action applied to a set of selected rows. Filament: `BulkAction`.
class BulkAction<T> extends FilamentAction {
  final BulkActionHandler<T> onPressed;

  const BulkAction({
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
