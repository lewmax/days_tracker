import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/class_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when StatefulWidget calls setState after `await` without checking
/// `mounted` or `context.mounted`.
class CheckWidgetMountedAfterAsync extends DartLintRule {
  const CheckWidgetMountedAfterAsync() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'check_widget_mounted_after_async',
    problemMessage:
        "Check 'mounted' or 'context.mounted' before calling setState after "
        "an async gap. Add 'if (!context.mounted) return;' after the await.",
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclaration((node) {
      if (!node.body.isAsynchronous) return;

      final enclosingClass = node.thisOrAncestorOfType<ClassDeclaration>();
      if (enclosingClass == null || !ClassUtils.isState(enclosingClass)) return;

      _analyzeBody(node.body, reporter);
    });
  }

  void _analyzeBody(FunctionBody body, DiagnosticReporter reporter) {
    final visitor = _WidgetAsyncVisitor(reporter);
    body.accept(visitor);
  }
}

class _WidgetAsyncVisitor extends GeneralizingAstVisitor<void> {
  _WidgetAsyncVisitor(this._reporter);

  final DiagnosticReporter _reporter;

  int? _lastAwaitEndOffset;
  bool _hasSeenMountedGuard = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _lastAwaitEndOffset = node.end;
    _hasSeenMountedGuard = false;
    super.visitAwaitExpression(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    if (_isMountedGuard(node)) {
      _hasSeenMountedGuard = true;
    }
    super.visitIfStatement(node);
  }

  bool _isMountedGuard(IfStatement node) {
    final cond = node.expression;
    // if (!context.mounted) return;
    if (cond is PrefixExpression && cond.operator.lexeme == '!') {
      final operand = cond.operand;
      if (operand is PropertyAccess) {
        return operand.propertyName.name == 'mounted';
      }
      if (operand is PrefixedIdentifier) {
        return operand.identifier.name == 'mounted';
      }
    }
    // if (context.mounted) { setState(...); }
    if (cond is PropertyAccess) {
      return cond.propertyName.name == 'mounted';
    }
    if (cond is PrefixedIdentifier) {
      return cond.identifier.name == 'mounted';
    }
    // if (!mounted) return; (State has mounted getter)
    if (cond is SimpleIdentifier) {
      return cond.name == 'mounted';
    }
    if (cond is PrefixExpression && cond.operator.lexeme == '!') {
      final operand = cond.operand;
      if (operand is SimpleIdentifier) return operand.name == 'mounted';
    }
    return false;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setState' && _lastAwaitEndOffset != null) {
      if (node.offset > _lastAwaitEndOffset! && !_hasSeenMountedGuard) {
        _reporter.atOffset(
          diagnosticCode: CheckWidgetMountedAfterAsync._lintCode,
          offset: node.offset,
          length: node.length,
        );
      }
    }
    super.visitMethodInvocation(node);
  }
}
