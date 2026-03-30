import 'package:analyzer/dart/ast/ast.dart';

/// Class and AST-related utilities for lint rules.
class ClassUtils {
  ClassUtils._();

  /// Returns the name of the type the class extends, or null if none.
  static String? getExtendedTypeName(ClassDeclaration node) {
    final ext = node.extendsClause?.superclass;
    if (ext == null) return null;
    return ext.name.lexeme;
  }

  /// Returns true if the class extends State.
  static bool isState(ClassDeclaration node) {
    return getExtendedTypeName(node) == 'State';
  }

  /// Returns true if the class extends Bloc, Cubit, or BlocBase.
  static bool isBlocOrCubit(ClassDeclaration node) {
    final name = getExtendedTypeName(node);
    return name == 'Bloc' || name == 'Cubit' || name == 'BlocBase';
  }

  /// Returns true if the class extends State, Bloc, Cubit, or BlocBase.
  static bool isStateOrBloc(ClassDeclaration node) {
    final name = getExtendedTypeName(node);
    return name == 'State' || name == 'Bloc' || name == 'Cubit' || name == 'BlocBase';
  }

  /// Returns true if the class has a dispose method.
  static bool hasDispose(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        return true;
      }
    }
    return false;
  }
}
