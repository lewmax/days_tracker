import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/import_utils.dart';
import 'package:days_tracker_lint/src/utils/path_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when a feature imports from another feature.
/// Features under presentation/features/X may only import from core, domain, data,
/// presentation/common, and presentation/features/X (same feature).
class AvoidCrossFeatureImports extends DartLintRule {
  const AvoidCrossFeatureImports() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'avoid_cross_feature_imports',
    problemMessage:
        'Features must not import from other features. '
        'Import from core, domain, data, or presentation/common instead.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    final currentFeature = PathUtils.getFeatureName(resolver.path);
    if (currentFeature == null) return;
    if (PathUtils.isGeneratedFile(resolver.path)) return;

    context.registry.addImportDirective((node) {
      final targetFeature = ImportUtils.getImportTargetFeature(node.uri.stringValue ?? '');
      if (targetFeature == null) return; // Not a feature import
      if (targetFeature == currentFeature) return; // Same feature OK
      reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
    });
  }
}
