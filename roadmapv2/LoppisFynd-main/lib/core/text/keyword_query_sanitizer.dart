String? sanitizeKeywordQuery(
  String? input, {
  int maxTokens = 5,
  int minChars = 2,
  int maxChars = 80,
}) {
  final trimmed = input?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final tokens = trimmed
      .split(RegExp(r'\s+'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .take(maxTokens)
      .toList(growable: false);

  if (tokens.isEmpty) return null;

  var joined = tokens.join(' ');
  if (joined.length > maxChars) {
    joined = joined.substring(0, maxChars).trimRight();
  }

  return joined.length < minChars ? null : joined;
}
