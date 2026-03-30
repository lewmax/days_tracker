import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/import_utils.dart';
import 'package:days_tracker_lint/src/utils/path_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when domain layer files import package:flutter.
class NoFlutterImportInDomain extends DartLintRule {
  const NoFlutterImportInDomain() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'no_flutter_import_in_domain',
    problemMessage:
        'Domain layer should not import package:flutter. '
        'Keep business logic framework-independent.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addImportDirective((node) {
      if (!PathUtils.isDomainFile(resolver.path)) return;
      final uri = node.uri.stringValue ?? '';
      if (ImportUtils.isFlutterImport(uri)) {
        reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
      }
    });
  }
}
