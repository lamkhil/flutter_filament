/// Flutter Filament - A Filament 5-inspired admin panel framework for Flutter.
///
/// Mirrors Filament's mental model:
///   Panel ──► Resource ──► Pages (list / create / edit / view)
///                      └──► Form schema + Table schema
///          ──► Widgets  (stat / chart / table)
///          ──► Pages    (custom pages)
library;

// Theme
export 'src/theme/filament_colors.dart';
export 'src/theme/filament_theme.dart';

// Data layer
export 'src/data/data_source.dart';
export 'src/data/paginated_result.dart';
export 'src/data/memory_data_source.dart';

// Forms
export 'src/forms/form_schema.dart';
export 'src/forms/form_component.dart';
export 'src/forms/form_state.dart';
export 'src/forms/form_builder_widget.dart';
export 'src/forms/components/text_input.dart';
export 'src/forms/components/textarea.dart';
export 'src/forms/components/select.dart';
export 'src/forms/components/toggle.dart';
export 'src/forms/components/checkbox.dart';
export 'src/forms/components/checkbox_list.dart';
export 'src/forms/components/date_picker.dart';
export 'src/forms/components/number_input.dart';
export 'src/forms/components/section.dart';
export 'src/forms/components/grid_layout.dart';

// Tables
export 'src/tables/table_schema.dart';
export 'src/tables/table_column.dart';
export 'src/tables/table_filter.dart';
export 'src/tables/table_builder_widget.dart';
export 'src/tables/columns/text_column.dart';
export 'src/tables/columns/badge_column.dart';
export 'src/tables/columns/date_column.dart';
export 'src/tables/columns/icon_column.dart';
export 'src/tables/columns/boolean_column.dart';

// Actions
export 'src/actions/action.dart';
export 'src/actions/row_action.dart';
export 'src/actions/header_action.dart';
export 'src/actions/bulk_action.dart';

// Resource, pages & relations
export 'src/resource/resource.dart';
export 'src/resource/resource_page.dart';
export 'src/resource/resource_context.dart';
export 'src/resource/relation_manager.dart';
export 'src/pages/filament_page.dart';
export 'src/pages/list_records_page.dart';
export 'src/pages/create_record_page.dart';
export 'src/pages/edit_record_page.dart';
export 'src/pages/view_record_page.dart';

// Dashboard & layout widgets
export 'src/widgets/dashboard_widget.dart';
export 'src/widgets/stat_widget.dart';
export 'src/widgets/chart_widget.dart';
export 'src/widgets/table_widget.dart';
export 'src/widgets/relation_tabs.dart';

// Panel & navigation
export 'src/panel/panel.dart';
export 'src/panel/panel_provider.dart';

// Tenancy
export 'src/tenant/tenant_config.dart';
export 'src/tenant/tenant_access.dart';
export 'src/tenant/tenant_scope.dart';
export 'src/tenant/tenant_switcher.dart';
export 'src/navigation/navigation_item.dart';
export 'src/navigation/navigation_group.dart';
export 'src/layout/panel_layout.dart';
export 'src/layout/dashboard_page.dart';
