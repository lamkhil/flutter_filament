import 'package:flutter/material.dart';
import 'filament_colors.dart';

/// Theme container for a Filament Panel.
/// Provides semantic colors + typography used by all built-in widgets.
class FilamentTheme {
  final FilamentColors colors;
  final Brightness brightness;
  final double borderRadius;
  final String? fontFamily;

  const FilamentTheme({
    this.colors = FilamentColors.amber,
    this.brightness = Brightness.light,
    this.borderRadius = 8,
    this.fontFamily,
  });

  bool get isDark => brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
  Color get surface => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get border =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
  Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF111827);
  Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  Color get textMuted =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);

  /// Converts to Flutter [ThemeData].
  ThemeData toThemeData() {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
    );
  }

  FilamentTheme copyWith({
    FilamentColors? colors,
    Brightness? brightness,
    double? borderRadius,
    String? fontFamily,
  }) =>
      FilamentTheme(
        colors: colors ?? this.colors,
        brightness: brightness ?? this.brightness,
        borderRadius: borderRadius ?? this.borderRadius,
        fontFamily: fontFamily ?? this.fontFamily,
      );
}

/// InheritedWidget that exposes the active [FilamentTheme] to the subtree.
class FilamentThemeScope extends InheritedWidget {
  final FilamentTheme theme;
  const FilamentThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  static FilamentTheme of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FilamentThemeScope>();
    return scope?.theme ?? const FilamentTheme();
  }

  @override
  bool updateShouldNotify(FilamentThemeScope oldWidget) =>
      theme != oldWidget.theme;
}
