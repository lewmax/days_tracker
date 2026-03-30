import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when methods named `get*` return void or don't return a value.
class PreferGetPrefixReturnsValue extends DartLintRule {
  const PreferGetPrefixReturnsValue() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'prefer_get_prefix_returns_value',
    problemMessage:
        'Methods named get* should return a value. '
        "Rename to remove the 'get' prefix or return a non-void value.",
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclaration((node) {
      final name = node.name.lexeme;
      if (!name.startsWith('get') || name.length <= 3) return;

      final element = node.declaredFragment?.element;
      if (element == null) return;

      final returnType = element.returnType;
      if (returnType is VoidType) {
        reporter.atOffset(
          diagnosticCode: _lintCode,
          offset: node.name.offset,
          length: node.name.length,
        );
      }
    });
  }
}
