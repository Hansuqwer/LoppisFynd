class IsbnValidator {
  const IsbnValidator();

  String normalize(String raw) {
    return raw.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  bool isValid(String raw) {
    final normalized = normalize(raw);
    if (normalized.length == 10) {
      return isValidIsbn10(normalized);
    }
    if (normalized.length == 13) {
      return isValidIsbn13(normalized);
    }
    return false;
  }

  bool isValidIsbn10(String normalized) {
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(normalized)) {
      return false;
    }

    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += int.parse(normalized[i]) * (10 - i);
    }
    final check = normalized[9] == 'X' ? 10 : int.parse(normalized[9]);
    return (sum + check) % 11 == 0;
  }

  bool isValidIsbn13(String normalized) {
    if (!RegExp(r'^\d{13}$').hasMatch(normalized)) {
      return false;
    }
    if (!normalized.startsWith('978') && !normalized.startsWith('979')) {
      return false;
    }

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(normalized[i]);
      sum += digit * (i.isEven ? 1 : 3);
    }
    final check = int.parse(normalized[12]);
    return (10 - (sum % 10)) % 10 == check;
  }
}
