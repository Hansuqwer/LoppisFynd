import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoHardcodedUiStrings extends DartLintRule {
  const NoHardcodedUiStrings()
    : super(
        code: const LintCode(
          name: 'no_hardcoded_ui_strings',
          problemMessage:
              'Avoid hardcoded user-facing strings; use AppLocalizations instead.',
        ),
      );

  static bool _isInLib(String fullPath) {
    final normalized = fullPath.replaceAll('\\\\', '/');
    return normalized.contains('/lib/') &&
        !normalized.contains('/lib/gen/') &&
        !normalized.contains('/lib/l10n/');
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!_isInLib(resolver.source.fullName)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeSource = node.constructorName.type.toSource();
      final typeName = typeSource.split('<').first;

      switch (typeName) {
        case 'Text':
          _checkText(node, reporter);
          break;
        case 'TextSpan':
          _checkNamedStringArg(node, reporter, const {'text'});
          break;
        case 'InputDecoration':
          _checkNamedStringArg(node, reporter, const {
            'labelText',
            'hintText',
            'helperText',
            'errorText',
          });
          break;
        case 'Tooltip':
          _checkNamedStringArg(node, reporter, const {'message'});
          break;
        case 'Semantics':
          _checkNamedStringArg(node, reporter, const {'label', 'hint'});
          break;
      }
    });
  }

  void _checkText(
    InstanceCreationExpression node,
    DiagnosticReporter reporter,
  ) {
    final args = node.argumentList.arguments;

    if (args.isEmpty) return;
    final first = args.first;
    if (first is StringLiteral) {
      reporter.atNode(first, code);
    }
  }

  void _checkNamedStringArg(
    InstanceCreationExpression node,
    DiagnosticReporter reporter,
    Set<String> names,
  ) {
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      if (!names.contains(arg.name.label.name)) continue;

      final expression = arg.expression;
      if (expression is StringLiteral) {
        reporter.atNode(expression, code);
      }
    }
  }
}
