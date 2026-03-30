import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:days_tracker_lint/src/utils/class_utils.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when Bloc/Cubit uses BuildContext directly (should use callbacks/streams).
class NoBuildContextInBusinessLogic extends DartLintRule {
  const NoBuildContextInBusinessLogic() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'no_build_context_in_business_logic',
    problemMessage: 'Avoid BuildContext in Bloc/Cubit. Use callbacks, streams, or events.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.isBlocOrCubit(node)) return;
      final contextParams = _findBuildContextParameters(node);
      for (final param in contextParams) {
        reporter.atOffset(diagnosticCode: _lintCode, offset: param.offset, length: param.length);
      }
    });

    // Also check for BuildContext type in field declarations
    context.registry.addFieldDeclaration((node) {
      final enclosing = node.thisOrAncestorOfType<ClassDeclaration>();
      if (enclosing == null || !ClassUtils.isBlocOrCubit(enclosing)) return;
      final typeAnnotation = node.fields.type;
      if (typeAnnotation != null && typeAnnotation.toString().contains('BuildContext')) {
        reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
      }
    });
  }

  List<SimpleFormalParameter> _findBuildContextParameters(ClassDeclaration node) {
    final result = <SimpleFormalParameter>[];
    for (final member in node.members) {
      if (member is ConstructorDeclaration) {
        for (final param in member.parameters.parameters) {
          if (param is SimpleFormalParameter) {
            final type = param.type;
            if (type != null && type.toString().contains('BuildContext')) {
              result.add(param);
            }
          }
        }
      }
      if (member is MethodDeclaration) {
        for (final param in member.parameters?.parameters ?? []) {
          if (param is SimpleFormalParameter) {
            final type = param.type;
            if (type != null && type.toString().contains('BuildContext')) {
              result.add(param);
            }
          }
        }
      }
    }
    return result;
  }
}
