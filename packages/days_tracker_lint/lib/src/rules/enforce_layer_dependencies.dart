import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/import_utils.dart';
import 'package:days_tracker_lint/src/utils/path_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Enforces layer dependency direction: domain ← data ← presentation (blocs) ← presentation (pages).
/// - Domain: may import domain, core, and any external packages; may NOT import data, presentation.
/// - Data: may import domain, core, data; may NOT import presentation or Flutter.
/// - Presentation (blocs): may import domain, data, core, and other blocs; may NOT import pages.
/// - Presentation (ui): may import domain, data, core, blocs, and other pages.
class EnforceLayerDependencies extends DartLintRule {
  const EnforceLayerDependencies() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'enforce_layer_dependencies',
    problemMessage:
        'Layer dependency violation. Dependencies must flow inward: '
        'domain (no deps) ← data ← presentation (blocs) ← presentation (pages).',
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
      // External package: domain and data may import; data may not import Flutter
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
        // Blocs cannot import ui; ui can import blocs.
        if (presentationSubLayer == 'bloc') {
          final targetSubLayer = ImportUtils.getImportTargetPresentationSubLayer(uri);
          return targetSubLayer == 'ui'; // Bloc importing ui = violation
        }
        return false; // Ui can import anything in presentation
      case 'core':
        return false; // Core can import any layer
      default:
        return false;
    }
  }
}
