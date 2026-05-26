import 'isbn_validator.dart';

class ValidatedBookIsbn {
  const ValidatedBookIsbn._(this.value);

  factory ValidatedBookIsbn.fromScannerValue(
    String raw, {
    IsbnValidator validator = const IsbnValidator(),
  }) {
    if (!validator.isValid(raw)) {
      throw FormatException('Invalid ISBN barcode value: $raw');
    }
    return ValidatedBookIsbn._(validator.normalize(raw));
  }

  final String value;
}
