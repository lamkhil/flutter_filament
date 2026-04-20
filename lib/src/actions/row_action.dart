import 'package:flutter/material.dart';
import 'action.dart';

typedef RowActionHandler<T> = Future<void> Function(BuildContext context, T row);
typedef RowActionVisibility<T> = bool Function(T row);

/// Action on a single row (edit / delete / custom).
/// Filament: `Tables\Actions\Action`.
class RowAction<T> extends FilamentAction {
  final RowActionHandler<T> onPressed;
  final RowActionVisibility<T>? visibleWhen;

  const RowAction({
    required super.name,
    required super.label,
    required this.onPressed,
    super.icon,
    super.color,
    super.requiresConfirmation,
    super.confirmationTitle,
    super.confirmationMessage,
    this.visibleWhen,
  });

  bool isVisible(T row) => visibleWhen?.call(row) ?? true;

  /// Helper factory for a standard edit action.
  static RowAction<T> edit<T>(RowActionHandler<T> onPressed) => RowAction<T>(
        name: 'edit',
        label: 'Edit',
        icon: Icons.edit_outlined,
        color: ActionColor.primary,
        onPressed: onPressed,
      );

  /// Helper factory for a standard view action.
  static RowAction<T> view<T>(RowActionHandler<T> onPressed) => RowAction<T>(
        name: 'view',
        label: 'Lihat',
        icon: Icons.visibility_outlined,
        color: ActionColor.info,
        onPressed: onPressed,
      );

  /// Helper factory for a delete action with confirmation dialog.
  static RowAction<T> delete<T>(RowActionHandler<T> onPressed) => RowAction<T>(
        name: 'delete',
        label: 'Hapus',
        icon: Icons.delete_outline,
        color: ActionColor.danger,
        requiresConfirmation: true,
        confirmationTitle: 'Hapus data?',
        confirmationMessage:
            'Aksi ini tidak dapat dibatalkan. Lanjutkan?',
        onPressed: onPressed,
      );
}
