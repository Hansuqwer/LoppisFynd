class AiJsonExtractor {
  static String extractFirstJsonObject(String text) {
    final start = text.indexOf('{');
    if (start < 0) {
      throw const FormatException('No JSON object found');
    }

    var depth = 0;
    var inString = false;
    var escape = false;

    for (var i = start; i < text.length; i++) {
      final ch = text.codeUnitAt(i);

      if (inString) {
        if (escape) {
          escape = false;
          continue;
        }
        if (ch == 0x5C) {
          escape = true;
          continue;
        }
        if (ch == 0x22) {
          inString = false;
        }
        continue;
      }

      if (ch == 0x22) {
        inString = true;
        continue;
      }

      if (ch == 0x7B) {
        depth++;
        continue;
      }
      if (ch == 0x7D) {
        depth--;
        if (depth == 0) {
          return text.substring(start, i + 1);
        }
        if (depth < 0) {
          break;
        }
      }
    }

    throw const FormatException('Unterminated JSON object');
  }
}
