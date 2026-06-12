import 'package:intl/intl.dart' as intl;

String formatSekAmount(double value) {
  final formatter = intl.NumberFormat.decimalPattern(
    intl.Intl.getCurrentLocale(),
  );
  return formatter.format(value.round());
}
