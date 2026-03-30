import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/class_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when State creates controllers but doesn't dispose them.
class DisposeControllers extends DartLintRule {
  const DisposeControllers() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'dispose_controllers',
    problemMessage:
        'Controller must be disposed or canceled in dispose(). '
        'Use .dispose() for controllers, .cancel() for Timer/StreamSubscription.',
  );

  static const _controllerTypes = [
    // Flutter controllers
    'TextEditingController',
    'AnimationController',
    'ScrollController',
    'PageController',
    'TabController',
    'TransformationController',
    // Async / streams
    'StreamController',
    'StreamSubscription',
    // Timers
    'Timer',
    // Flutter focus / overlays
    'FocusNode',
    'FocusScopeNode',
    'OverlayEntry',
  ];

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.isState(node)) return;
      final controllerFields = _findControllerFields(node);
      final disposedInDispose = _findDisposedInDispose(node);
      for (final variable in controllerFields) {
        if (!disposedInDispose.contains(variable.name.lexeme)) {
          reporter.atOffset(
            diagnosticCode: _lintCode,
            offset: variable.offset,
            length: variable.length,
          );
        }
      }
    });
  }

  List<VariableDeclaration> _findControllerFields(ClassDeclaration node) {
    final result = <VariableDeclaration>[];
    for (final member in node.members) {
      if (member is FieldDeclaration) {
        final type = member.fields.type;
        if (type != null) {
          final typeStr = type.toString();
          if (_controllerTypes.any((t) => typeStr.contains(t))) {
            for (final v in member.fields.variables) {
              result.add(v);
            }
          }
        }
      }
    }
    return result;
  }

  Set<String> _findDisposedInDispose(ClassDeclaration node) {
    MethodDeclaration? disposeMethod;
    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        disposeMethod = member;
        break;
      }
    }
    if (disposeMethod == null) return {};

    final visitor = _DisposeCallVisitor();
    disposeMethod.visitChildren(visitor);
    return visitor.disposedNames;
  }
}

class _DisposeCallVisitor extends RecursiveAstVisitor<void> {
  final Set<String> disposedNames = {};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (name == 'dispose' || name == 'cancel') {
      final target = node.target;
      if (target is SimpleIdentifier) {
        disposedNames.add(target.name);
      }
      if (target is PropertyAccess) {
        disposedNames.add(target.propertyName.name);
      }
    }
    super.visitMethodInvocation(node);
  }
}
