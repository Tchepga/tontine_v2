/// Aligné sur `username-generator.ts` côté API (aperçu avant inscription).
class UsernameHelper {
  static String buildPreview(String firstname, String lastname) {
    final base = '${_normalizePart(firstname)}.${_normalizePart(lastname)}';
    if (base == '.' || base.isEmpty) {
      return 'prenom.nom';
    }
    return base;
  }

  static String _normalizePart(String value) {
    return _removeDiacritics(value)
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\s_-]+'), '');
  }

  static String _removeDiacritics(String input) {
    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'æ': 'ae',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ø': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'œ': 'oe',
    };

    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(accents[char] ?? accents[char.toLowerCase()] ?? char);
    }
    return buffer.toString();
  }
}
