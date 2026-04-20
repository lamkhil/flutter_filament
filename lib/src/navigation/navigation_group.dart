import 'package:flutter/widgets.dart';
import 'navigation_item.dart';

/// A group of sidebar items rendered under a shared label.
class NavigationGroup {
  final String? label;
  final IconData? icon;
  final List<NavigationItem> items;
  final bool collapsible;
  final int sort;

  const NavigationGroup({
    this.label,
    this.icon,
    required this.items,
    this.collapsible = false,
    this.sort = 0,
  });
}
