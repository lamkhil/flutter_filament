import 'package:flutter/widgets.dart';

/// A single item in the sidebar.
class NavigationItem {
  final String label;
  final IconData icon;
  final String path;
  final String? badge;
  final Color? badgeColor;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.path,
    this.badge,
    this.badgeColor,
  });
}
