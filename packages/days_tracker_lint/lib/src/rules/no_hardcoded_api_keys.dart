import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns on string literals that look like API keys or secrets.
class NoHardcodedApiKeys extends DartLintRule {
  const NoHardcodedApiKeys() : super(code: _lintCode);

  static const _lintCode = LintCode(
    name: 'no_hardcoded_api_keys',
    problemMessage:
        'Avoid hardcoded API keys or secrets. Use environment variables or secure config.',
  );

  // Patterns that suggest API keys or secrets (high precision to reduce false positives)
  static final _suspiciousPatterns = [
    RegExp(r'^[A-Za-z0-9_-]{32,}$'), // Long alphanumeric strings (e.g. API keys)
    RegExp('^sk-[A-Za-z0-9]{20,}'), // Stripe secret key pattern
    RegExp('^pk_[A-Za-z0-9]{20,}'), // Stripe public key pattern
    RegExp('^AIza[A-Za-z0-9_-]{35}'), // Google API key pattern
  ];

  static const _suspiciousSubstrings = [
    'api_key',
    'apiKey',
    'apikey',
    'secret_key',
    'secretKey',
    'access_token',
    'accessToken',
  ];

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addSimpleStringLiteral((node) {
      final value = node.value;
      if (value.isEmpty || value.length < 20) return;

      // Check if in a place that suggests a key (variable name, etc.)
      final parent = node.parent;
      if (parent is NamedExpression) {
        final name = parent.name.label.name;
        if (_looksLikeKeyName(name) && _looksLikeKeyValue(value)) {
          reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
        }
      }

      // Check variable declaration: final apiKey = 'xxx'
      if (parent is VariableDeclaration) {
        final name = parent.name.lexeme;
        if (_looksLikeKeyName(name) && _looksLikeKeyValue(value)) {
          reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
        }
      }

      // Check map literal: {'api_key': 'xxx'} - we are the value, key is parent.key
      if (parent is MapLiteralEntry && parent.value == node) {
        final keyStr = parent.key.toString();
        if (_looksLikeKeyName(keyStr) && _looksLikeKeyValue(value)) {
          reporter.atOffset(diagnosticCode: _lintCode, offset: node.offset, length: node.length);
        }
      }
    });
  }

  bool _looksLikeKeyName(String name) {
    final lower = name.toLowerCase();
    return _suspiciousSubstrings.any((s) => lower.contains(s));
  }

  bool _looksLikeKeyValue(String value) {
    if (value.length < 20) return false;
    return _suspiciousPatterns.any((p) => p.hasMatch(value)) ||
        (RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value) && value.length > 32);
  }
}
