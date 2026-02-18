import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoAdHocDesignConstants extends DartLintRule {
  const NoAdHocDesignConstants()
    : super(
        code: const LintCode(
          name: 'no_ad_hoc_design_constants',
          problemMessage:
              'Avoid ad-hoc design constants in shared UI; prefer design tokens.',
        ),
      );

  static bool _isInGuardrailScope(String fullPath) {
    final normalized = fullPath.replaceAll('\\\\', '/');

    // Start strict in shared primitives; expand scope over time.
    return normalized.contains('/lib/shared/widgets/') &&
        !normalized.contains('/lib/shared/widgets/atmospheric_background.dart');
  }

  static bool _isNumericLiteral(Expression expr) {
    if (expr is IntegerLiteral) return true;
    if (expr is DoubleLiteral) return true;
    if (expr is PrefixExpression &&
        expr.operator.lexeme == '-' &&
        (expr.operand is IntegerLiteral || expr.operand is DoubleLiteral)) {
      return true;
    }
    return false;
  }

  static bool _isZero(Expression expr) {
    if (expr is IntegerLiteral) return expr.value == 0;
    if (expr is DoubleLiteral) return expr.value == 0.0;
    if (expr is PrefixExpression && expr.operator.lexeme == '-') {
      return _isZero(expr.operand);
    }
    return false;
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!_isInGuardrailScope(resolver.source.fullName)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeSource = node.constructorName.type.toSource();
      final typeName = typeSource.split('<').first;

      switch (typeName) {
        case 'EdgeInsets':
          _checkEdgeInsets(node, reporter);
          break;
        case 'BoxShadow':
          _checkBoxShadow(node, reporter);
          break;
        case 'Offset':
          // Offset is flagged only when directly inside a BoxShadow via named
          // argument scanning, to avoid excessive noise.
          break;
      }
    });

    context.registry.addMethodInvocation((node) {
      final targetType = node.target?.toSource();
      final methodName = node.methodName.name;
      if (targetType == 'ImageFilter' && methodName == 'blur') {
        _checkImageFilterBlur(node, reporter);
      }
    });
  }

  void _checkEdgeInsets(
    InstanceCreationExpression node,
    ErrorReporter reporter,
  ) {
    // Flags EdgeInsets.* where any direct numeric literal appears.
    for (final arg in node.argumentList.arguments) {
      final expr = arg is NamedExpression ? arg.expression : arg;
      if (_isNumericLiteral(expr) && !_isZero(expr)) {
        reporter.atNode(expr, code);
      }
    }
  }

  void _checkImageFilterBlur(MethodInvocation node, ErrorReporter reporter) {
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;
      if (name != 'sigmaX' && name != 'sigmaY') continue;

      final expr = arg.expression;
      if (_isNumericLiteral(expr) && !_isZero(expr)) {
        reporter.atNode(expr, code);
      }
    }
  }

  void _checkBoxShadow(
    InstanceCreationExpression node,
    ErrorReporter reporter,
  ) {
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;

      final name = arg.name.label.name;
      final expr = arg.expression;

      if (name == 'blurRadius' || name == 'spreadRadius') {
        if (_isNumericLiteral(expr) && !_isZero(expr)) {
          reporter.atNode(expr, code);
        }
      }

      if (name == 'offset' && expr is InstanceCreationExpression) {
        final offsetType = expr.constructorName.type
            .toSource()
            .split('<')
            .first;
        if (offsetType != 'Offset') continue;

        for (final offsetArg in expr.argumentList.arguments) {
          final offExpr = offsetArg is NamedExpression
              ? offsetArg.expression
              : offsetArg;
          if (_isNumericLiteral(offExpr) && !_isZero(offExpr)) {
            reporter.atNode(offExpr, code);
          }
        }
      }
    }
  }
}
