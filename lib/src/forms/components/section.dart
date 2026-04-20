import 'package:flutter/material.dart';
import '../../theme/filament_theme.dart';
import '../form_component.dart';
import '../form_schema.dart';
import '../form_state.dart';

/// Groups related fields under a titled card. Filament: `Section::make('Info')`.
class Section extends FormLayoutComponent {
  final String title;
  final String? description;
  final IconData? icon;
  @override
  final List<FormComponent> children;
  final int columns;
  final bool collapsible;

  Section({
    required this.title,
    required this.children,
    this.description,
    this.icon,
    this.columns = 1,
    this.collapsible = false,
  });

  @override
  Widget build(BuildContext context, FormStateController state) {
    return _SectionView(section: this, state: state);
  }
}

class _SectionView extends StatefulWidget {
  final Section section;
  final FormStateController state;
  const _SectionView({required this.section, required this.state});

  @override
  State<_SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<_SectionView> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final s = widget.section;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: s.collapsible ? () => setState(() => _open = !_open) : null,
            child: Row(
              children: [
                if (s.icon != null) ...[
                  Icon(s.icon, size: 18, color: theme.colors.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.textPrimary,
                        ),
                      ),
                      if (s.description != null)
                        Text(
                          s.description!,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (s.collapsible)
                  Icon(_open ? Icons.expand_less : Icons.expand_more,
                      color: theme.textSecondary),
              ],
            ),
          ),
          if (_open || !s.collapsible) ...[
            const SizedBox(height: 16),
            _ColumnLayout(
              columns: s.columns,
              children: s.children,
              state: widget.state,
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders children in N-column responsive grid based on [Field.columnSpan].
class _ColumnLayout extends StatelessWidget {
  final int columns;
  final List<FormComponent> children;
  final FormStateController state;
  const _ColumnLayout({
    required this.columns,
    required this.children,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c.build(context, state),
                ))
            .toList(),
      );
    }
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final gap = 12.0;
        final totalGap = gap * (columns - 1);
        final colW = (constraints.maxWidth - totalGap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children.map((c) {
            final span = c is Field ? c.columnSpan.clamp(1, columns) : columns;
            final w = colW * span + gap * (span - 1);
            return SizedBox(width: w, child: c.build(ctx, state));
          }).toList(),
        );
      },
    );
  }
}

/// Exported for internal reuse by Grid/FormBuilderWidget.
class FormColumnLayout extends StatelessWidget {
  final int columns;
  final List<FormComponent> children;
  final FormStateController state;
  const FormColumnLayout({
    super.key,
    required this.columns,
    required this.children,
    required this.state,
  });

  @override
  Widget build(BuildContext context) => _ColumnLayout(
        columns: columns,
        children: children,
        state: state,
      );
}
