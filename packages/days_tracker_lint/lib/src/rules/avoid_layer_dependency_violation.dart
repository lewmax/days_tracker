import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/import_utils.dart';
import 'package:days_tracker_lint/src/utils/path_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags imports that violate layer boundaries (same logic as enforce_layer_dependencies).
/// Use this rule name if you prefer the "avoid" naming convention.
class AvoidLayerDependencyViolation extends DartLintRule {
  const AvoidLayerDependencyViolation() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'avoid_layer_dependency_violation',
    problemMessage:
        'This import violates layer boundaries. '
        'Blocs must not depend on pages; domain must not depend on data/presentation. Everyone may depend on core.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    final layer = PathUtils.getLayer(resolver.path);
    if (layer == null) return;
    if (PathUtils.isGeneratedFile(resolver.path)) return;

    final presentationSubLayer = PathUtils.getPresentationSubLayer(resolver.path);

    context.registry.addImportDirective((node) {
      final uri = node.uri.stringValue ?? '';
      if (!_isViolation(layer, presentationSubLayer, uri)) return;
      reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
    });
  }

  bool _isViolation(String currentLayer, String? presentationSubLayer, String uri) {
    if (ImportUtils.isDartImport(uri)) return false;

    final targetLayer = ImportUtils.getImportTargetLayer(uri);
    if (targetLayer == null) {
      if (ImportUtils.isFlutterImport(uri)) {
        return currentLayer == 'domain' || currentLayer == 'data';
      }
      return false; // Domain and data may import any non-Flutter external package
    }

    switch (currentLayer) {
      case 'domain':
        return targetLayer != 'domain' && targetLayer != 'core';
      case 'data':
        return targetLayer == 'presentation' || ImportUtils.isFlutterImport(uri);
      case 'presentation':
        if (presentationSubLayer == 'bloc') {
          final targetSubLayer = ImportUtils.getImportTargetPresentationSubLayer(uri);
          return targetSubLayer == 'page';
        }
        return false;
      case 'core':
        return false;
      default:
        return false;
    }
  }
}
