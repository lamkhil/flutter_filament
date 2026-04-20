import 'package:flutter/widgets.dart';

/// Base class for a dashboard widget shown on the Panel's home page.
/// Filament equivalent: `Filament\Widgets\Widget`.
abstract class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  /// Lower = appears earlier on the dashboard.
  int get sort => 0;

  /// How many of the dashboard's 12 grid columns this widget occupies on
  /// desktop. Mobile collapses everything to 12.
  int get columnSpan => 6;

  /// Optional group shown as a section header above the widget.
  String? get group => null;
}
