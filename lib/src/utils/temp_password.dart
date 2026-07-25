import 'dart:math';

/// Génère un mot de passe temporaire aléatoire (jamais de valeur fixe).
class TempPassword {
  TempPassword._();

  static const _chars =
      'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#\$%';

  static String generate({int length = 12}) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }
}
