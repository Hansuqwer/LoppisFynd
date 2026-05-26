import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/no_ad_hoc_design_constants.dart';
import 'src/no_hardcoded_ui_strings.dart';
import 'src/no_raw_backdrop_filter.dart';

PluginBase createPlugin() => _FyndLoppisLintsPlugin();

class _FyndLoppisLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
    NoRawBackdropFilter(),
    NoHardcodedUiStrings(),
    NoAdHocDesignConstants(),
  ];
}
