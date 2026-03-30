import 'package:days_tracker_lint/src/rules/avoid_cross_feature_imports.dart';
import 'package:days_tracker_lint/src/rules/check_bloc_is_not_closed_after_async.dart';
import 'package:days_tracker_lint/src/rules/check_widget_mounted_after_async.dart';
import 'package:days_tracker_lint/src/rules/dispose_controllers.dart';
import 'package:days_tracker_lint/src/rules/enforce_layer_dependencies.dart';
import 'package:days_tracker_lint/src/rules/no_build_context_in_business_logic.dart';
import 'package:days_tracker_lint/src/rules/no_direct_iterable_access.dart';
import 'package:days_tracker_lint/src/rules/no_flutter_import_in_domain.dart';
import 'package:days_tracker_lint/src/rules/no_hardcoded_api_keys.dart';
import 'package:days_tracker_lint/src/rules/prefer_get_prefix_returns_value.dart';
import 'package:days_tracker_lint/src/rules/prefer_stream_subscription_cancellation.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _CreditKasaLint();

class _CreditKasaLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const AvoidCrossFeatureImports(),
    const CheckBlocIsNotClosedAfterAsync(),
    const CheckWidgetMountedAfterAsync(),
    const DisposeControllers(),
    const EnforceLayerDependencies(),
    const NoBuildContextInBusinessLogic(),
    const NoDirectIterableAccess(),
    const NoFlutterImportInDomain(),
    const NoHardcodedApiKeys(),
    const PreferGetPrefixReturnsValue(),
    const PreferStreamSubscriptionCancellation(),
  ];
}
