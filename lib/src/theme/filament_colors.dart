import 'package:flutter/material.dart';

/// Filament-style semantic color palette.
/// Mirrors the Tailwind-based palette Filament uses (primary, success,
/// warning, danger, info, gray).
class FilamentColors {
  final Color primary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color gray;

  const FilamentColors({
    this.primary = const Color(0xFFF59E0B),
    this.success = const Color(0xFF10B981),
    this.warning = const Color(0xFFF59E0B),
    this.danger = const Color(0xFFEF4444),
    this.info = const Color(0xFF3B82F6),
    this.gray = const Color(0xFF6B7280),
  });

  static const amber = FilamentColors();
  static const blue = FilamentColors(primary: Color(0xFF3B82F6));
  static const emerald = FilamentColors(primary: Color(0xFF10B981));
  static const rose = FilamentColors(primary: Color(0xFFF43F5E));
  static const indigo = FilamentColors(primary: Color(0xFF6366F1));
  static const slate = FilamentColors(primary: Color(0xFF475569));

  FilamentColors copyWith({
    Color? primary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? gray,
  }) =>
      FilamentColors(
        primary: primary ?? this.primary,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        info: info ?? this.info,
        gray: gray ?? this.gray,
      );
}
