import 'package:flutter/widgets.dart';
import '../form_component.dart';
import '../form_schema.dart';
import '../form_state.dart';
import 'section.dart';

/// Arranges children into a column grid. Filament: `Grid::make(2)`.
class Grid extends FormLayoutComponent {
  final int columns;
  @override
  final List<FormComponent> children;

  Grid({required this.columns, required this.children});

  @override
  Widget build(BuildContext context, FormStateController state) =>
      FormColumnLayout(
        columns: columns,
        children: children,
        state: state,
      );
}
