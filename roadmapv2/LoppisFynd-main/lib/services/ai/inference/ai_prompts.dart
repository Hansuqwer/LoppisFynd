class AiPrompts {
  static String singleItemJsonPrompt() {
    return '''You are an expert Swedish second-hand reseller.

Task: Given one item photo, extract structured details.

Output: STRICT JSON ONLY (no markdown, no commentary) with this shape:
{
  "desc": "short user-facing description",
  "query": "Tradera search query",
  "confidence": 0.0,
  "attributes": {
    "brand": "",
    "model": "",
    "material": "",
    "era": ""
  }
}

Rules:
- confidence is 0.0..1.0
- query is 2..80 chars, Swedish terms preferred
- desc is 2..80 chars
''';
  }

  static String batchShelfJsonPrompt() {
    return '''You are an expert Swedish second-hand reseller.

Task: Given one photo of a shelf/table, identify up to 5 distinct items.

Output: STRICT JSON ONLY (no markdown, no commentary) with this shape:
{
  "items": [
    {"desc": "short", "query": "Tradera search query", "confidence": 0.0}
  ]
}

Rules:
- items length 0..5
- confidence is 0.0..1.0
- query is 2..80 chars
- desc is 2..80 chars
''';
  }
}
