import 'package:flutter/material.dart';
import '../layout/panel_layout.dart';

/// Base class for a page rendered inside a Panel's layout (sidebar + topbar).
/// Filament: `Filament\Pages\Page`.
abstract class FilamentPage extends StatelessWidget {
  const FilamentPage({super.key});

  /// Slug used in the URL inside the panel.
  String get slug;

  /// Title shown in the top bar and browser tab.
  String get title;

  /// Subtitle shown beneath the title.
  String? get subtitle => null;

  /// Icon for the sidebar entry.
  IconData get icon;

  /// Optional navigation group.
  String? get navigationGroup => null;
  int get navigationSort => 0;
  bool get hiddenFromNavigation => false;

  /// Header action buttons (right side of title row).
  List<Widget> buildHeaderActions(BuildContext context) => const [];

  /// The actual content rendered below the page header.
  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return PanelLayout(
      title: title,
      subtitle: subtitle,
      headerActions: buildHeaderActions(context),
      child: buildBody(context),
    );
  }
}
