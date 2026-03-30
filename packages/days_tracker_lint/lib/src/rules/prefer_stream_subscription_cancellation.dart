import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/class_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when a StreamSubscription is created but not canceled in dispose.
class PreferStreamSubscriptionCancellation extends DartLintRule {
  const PreferStreamSubscriptionCancellation() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'prefer_stream_subscription_cancellation',
    problemMessage: 'StreamSubscription should be stored and canceled in dispose().',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.hasDispose(node)) return;
      if (!ClassUtils.isStateOrBloc(node)) return; // Only State, Bloc, Cubit need to cancel
      final subscriptions = _findUnstoredSubscriptions(node);
      for (final sub in subscriptions) {
        reporter.atOffset(diagnosticCode: _lintCode, offset: sub.offset, length: sub.length);
      }
    });
  }

  List<AstNode> _findUnstoredSubscriptions(ClassDeclaration node) {
    final visitor = _SubscriptionVisitor();
    node.visitChildren(visitor);
    return visitor.unstoredSubscriptions;
  }
}

class _SubscriptionVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> unstoredSubscriptions = [];

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    // subscription = stream.listen(...) - stored, OK
    super.visitAssignmentExpression(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    // final subscription = stream.listen(...) - stored, OK
    super.visitVariableDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (name == 'listen') {
      // Check if this listen() result is stored or used
      if (_isStoredOrUsed(node)) return;
      unstoredSubscriptions.add(node);
    }
    super.visitMethodInvocation(node);
  }

  bool _isStoredOrUsed(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is AssignmentExpression) return true;
      if (current is VariableDeclaration) return true;
      if (current is ArgumentList) return true;
      if (current is AwaitExpression) return true;
      if (current is ReturnStatement) return true;
      if (current is ConditionalExpression) return true;
      current = current.parent;
    }
    return false;
  }
}
