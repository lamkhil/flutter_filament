import 'package:flutter/material.dart';
import 'components/section.dart';
import 'form_schema.dart';
import 'form_state.dart';

/// Renders a [FormSchema] and rebuilds reactive components when the
/// underlying [FormStateController] changes.
class FormBuilderWidget extends StatefulWidget {
  final FormSchema schema;
  final FormStateController state;

  const FormBuilderWidget({
    super.key,
    required this.schema,
    required this.state,
  });

  @override
  State<FormBuilderWidget> createState() => _FormBuilderWidgetState();
}

class _FormBuilderWidgetState extends State<FormBuilderWidget> {
  @override
  void initState() {
    super.initState();
    widget.schema.applyDefaults(widget.state);
    widget.state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => FormColumnLayout(
        columns: widget.schema.columns,
        children: widget.schema.components,
        state: widget.state,
      );
}
