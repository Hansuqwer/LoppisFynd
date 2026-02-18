import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoRawBackdropFilter extends DartLintRule {
  const NoRawBackdropFilter()
    : super(
        code: const LintCode(
          name: 'no_raw_backdrop_filter',
          problemMessage:
              'Use shared glass primitives instead of BackdropFilter directly.',
        ),
      );

  static bool _isAllowlisted(String path) {
    final normalized = path.replaceAll('\\\\', '/');

    if (normalized.endsWith('/lib/shared/widgets/capsule_nav_bar.dart')) {
      return true;
    }

    return normalized.contains('/lib/shared/widgets/glass_');
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    final sourcePath = resolver.source.fullName;
    if (_isAllowlisted(sourcePath)) return;

    context.registry.addInstanceCreationExpression((node) {
      final typeSource = node.constructorName.type.toSource();
      final typeName = typeSource.split('<').first;

      if (typeName == 'BackdropFilter') {
        reporter.atNode(node.constructorName.type, code);
      }
    });
  }
}
