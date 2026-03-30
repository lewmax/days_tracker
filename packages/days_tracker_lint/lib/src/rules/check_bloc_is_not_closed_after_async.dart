import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/class_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when Bloc/Cubit emits or adds events after `await` without checking `isClosed`.
class CheckBlocIsNotClosedAfterAsync extends DartLintRule {
  const CheckBlocIsNotClosedAfterAsync() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'check_bloc_is_not_closed_after_async',
    problemMessage:
        "Check 'isClosed' before emitting or adding events after an async gap. "
        "Add 'if (isClosed) return;' after the await.",
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclaration((node) {
      if (!node.body.isAsynchronous) return;

      final enclosingClass = node.thisOrAncestorOfType<ClassDeclaration>();
      if (enclosingClass == null || !ClassUtils.isBlocOrCubit(enclosingClass)) return;

      _analyzeBody(node.body, reporter);
    });
  }

  void _analyzeBody(FunctionBody body, DiagnosticReporter reporter) {
    final visitor = _BlocAsyncVisitor(reporter);
    body.accept(visitor);
  }
}

class _BlocAsyncVisitor extends GeneralizingAstVisitor<void> {
  _BlocAsyncVisitor(this._reporter);

  final DiagnosticReporter _reporter;

  int? _lastAwaitEndOffset;
  bool _hasSeenIsClosedGuard = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _lastAwaitEndOffset = node.end;
    _hasSeenIsClosedGuard = false;
    super.visitAwaitExpression(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    if (_isIsClosedGuard(node)) {
      _hasSeenIsClosedGuard = true;
    }
    super.visitIfStatement(node);
  }

  bool _isIsClosedGuard(IfStatement node) {
    final cond = node.expression;
    if (cond is SimpleIdentifier) return cond.name == 'isClosed';
    if (cond is PrefixExpression && cond.operator.lexeme == '!') {
      final operand = cond.operand;
      if (operand is SimpleIdentifier) return operand.name == 'isClosed';
    }
    return false;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if ((name == 'emit' || name == 'add') && _lastAwaitEndOffset != null) {
      if (node.offset > _lastAwaitEndOffset! && !_hasSeenIsClosedGuard) {
        _reporter.atOffset(
          diagnosticCode: CheckBlocIsNotClosedAfterAsync._lintCode,
          offset: node.offset,
          length: node.length,
        );
      }
    }
    super.visitMethodInvocation(node);
  }
}
