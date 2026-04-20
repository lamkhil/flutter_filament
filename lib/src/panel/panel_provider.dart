import 'package:flutter/widgets.dart';
import 'panel.dart';

/// InheritedWidget that makes the current [Panel] available to descendants.
/// Used by PanelLayout to render sidebar/topbar without prop drilling.
class PanelProvider extends InheritedWidget {
  final Panel panel;
  const PanelProvider({
    super.key,
    required this.panel,
    required super.child,
  });

  static Panel of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<PanelProvider>();
    assert(scope != null, 'No PanelProvider found in context.');
    return scope!.panel;
  }

  static Panel? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PanelProvider>()
      ?.panel;

  @override
  bool updateShouldNotify(PanelProvider oldWidget) => panel != oldWidget.panel;
}
