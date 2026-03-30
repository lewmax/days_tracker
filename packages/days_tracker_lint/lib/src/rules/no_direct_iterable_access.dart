import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/path_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags `.first`, `.last`, `.single` on Iterables without `.isNotEmpty` or length checks.
/// Does not flag Stream—Stream.first returns Future and has different semantics.
class NoDirectIterableAccess extends DartLintRule {
  const NoDirectIterableAccess() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'no_direct_iterable_access',
    problemMessage:
        'Unsafe access. Use .firstOrNull, .lastOrNull, or .singleOrNull, '
        'or guard with .isNotEmpty / length check before access.',
  );

  static const _streamChecker = TypeChecker.fromUrl('dart:async#Stream');
  static const _unsafeAccessors = ['first', 'last', 'single'];

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    if (PathUtils.isTestFile(resolver.path) || PathUtils.isGeneratedFile(resolver.path)) return;

    context.registry.addPropertyAccess((node) {
      final name = node.propertyName.name;
      if (!_unsafeAccessors.contains(name)) return;

      // Skip Stream—Stream.first returns Future, not the same as Iterable.first
      final targetType = node.target?.staticType;
      if (targetType != null && _streamChecker.isAssignableFromType(targetType)) return;

      if (_hasGuard(node)) return;

      reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
    });
  }

  /// Checks if there's an .isNotEmpty or length check guarding this access.
  bool _hasGuard(PropertyAccess node) {
    var current = node.parent;
    final targetStr = node.target.toString();

    while (current != null) {
      if (current is IfStatement) {
        final cond = current.expression.toString();
        if (cond.contains(targetStr) && (cond.contains('isNotEmpty') || cond.contains('length'))) {
          return true;
        }
      }
      if (current is ConditionalExpression) {
        final cond = current.condition.toString();
        if (cond.contains(targetStr) && (cond.contains('isNotEmpty') || cond.contains('length'))) {
          return true;
        }
      }
      current = current.parent;
    }
    return false;
  }
}
