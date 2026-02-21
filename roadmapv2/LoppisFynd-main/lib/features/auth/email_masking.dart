String maskEmailForUi(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';

  final at = value.indexOf('@');
  String local;
  String? domain;

  if (at == -1) {
    local = value;
  } else {
    local = value.substring(0, at);
    domain = value.substring(at + 1);
  }

  final plus = local.indexOf('+');
  if (plus != -1) {
    local = local.substring(0, plus);
  }

  final maskedLocal = _maskLocalPart(local);
  if (domain == null || domain.isEmpty) return maskedLocal;
  return '$maskedLocal@$domain';
}

String _maskLocalPart(String local) {
  if (local.isEmpty) return '•••';
  if (local.length <= 2) return '${local[0]}•';
  if (local.length == 3) return '${local.substring(0, 2)}•';
  return '${local.substring(0, 3)}•••';
}
