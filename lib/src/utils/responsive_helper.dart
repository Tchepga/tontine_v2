import 'package:flutter/material.dart';

/// Helper class pour gérer le design responsive selon la largeur ET la hauteur de l'écran
class ResponsiveHelper {
  // Breakpoints pour la largeur
  static const double smallWidth = 360.0;
  static const double mediumWidth = 600.0;

  // Breakpoints pour la hauteur
  static const double shortHeight = 600.0;
  static const double mediumHeight = 800.0;

  /// Détermine si l'écran est petit (largeur)
  static bool isSmallWidth(BuildContext context) {
    return MediaQuery.of(context).size.width < smallWidth;
  }

  /// Détermine si l'écran est moyen (largeur)
  static bool isMediumWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallWidth && width < mediumWidth;
  }

  /// Détermine si l'écran est grand (largeur)
  static bool isLargeWidth(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumWidth;
  }

  /// Détermine si l'écran est court (hauteur)
  static bool isShortHeight(BuildContext context) {
    return MediaQuery.of(context).size.height < shortHeight;
  }

  /// Détermine si l'écran est de hauteur moyenne
  static bool isMediumHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height >= shortHeight && height < mediumHeight;
  }

  /// Détermine si l'écran est grand (hauteur)
  static bool isTallHeight(BuildContext context) {
    return MediaQuery.of(context).size.height >= mediumHeight;
  }

  /// Retourne une valeur adaptative selon la largeur de l'écran
  static double getAdaptiveValue(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallWidth(context)) return small;
    if (isMediumWidth(context)) return medium;
    return large;
  }

  /// Retourne une valeur adaptative selon la hauteur de l'écran
  static double getAdaptiveHeightValue(
    BuildContext context, {
    required double short,
    required double medium,
    required double tall,
  }) {
    if (isShortHeight(context)) return short;
    if (isMediumHeight(context)) return medium;
    return tall;
  }

  /// Retourne une valeur adaptative selon les deux dimensions
  /// Utilise le facteur le plus restrictif (le plus petit)
  static double getAdaptiveValueCombined(
    BuildContext context, {
    required double smallShort,
    required double smallMedium,
    required double smallTall,
    required double mediumShort,
    required double mediumMedium,
    required double mediumTall,
    required double largeShort,
    required double largeMedium,
    required double largeTall,
  }) {
    final isSmallW = isSmallWidth(context);
    final isMediumW = isMediumWidth(context);
    final isLargeW = isLargeWidth(context);
    final isShortH = isShortHeight(context);
    final isMediumH = isMediumHeight(context);
    final isTallH = isTallHeight(context);

    if (isSmallW && isShortH) return smallShort;
    if (isSmallW && isMediumH) return smallMedium;
    if (isSmallW && isTallH) return smallTall;
    if (isMediumW && isShortH) return mediumShort;
    if (isMediumW && isMediumH) return mediumMedium;
    if (isMediumW && isTallH) return mediumTall;
    if (isLargeW && isShortH) return largeShort;
    if (isLargeW && isMediumH) return largeMedium;
    if (isLargeW && isTallH) return largeTall;

    return mediumMedium; // Default
  }

  /// Retourne un ratio adaptatif pour childAspectRatio selon largeur/hauteur
  static double getAdaptiveAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Sur très petits écrans, utiliser un ratio plus carré
    if (width < smallWidth) {
      return 0.9; // Plus carré pour petits écrans
    }

    // Sur écrans courts, réduire le ratio pour que les cartes soient moins hautes
    if (height < shortHeight) {
      return 1.1; // Plus large que haut
    }

    // Par défaut
    return 1.0;
  }

  /// Retourne le nombre de colonnes adaptatif pour GridView
  static int getAdaptiveCrossAxisCount(BuildContext context) {
    if (isSmallWidth(context)) {
      return 1; // 1 colonne sur petits écrans
    }
    return 2; // 2 colonnes sur écrans moyens/grands
  }

  /// Retourne un padding adaptatif selon les dimensions
  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    double hPadding = all ?? horizontal ?? 16.0;
    double vPadding = all ?? vertical ?? 16.0;

    // Réduire le padding horizontal sur petits écrans
    if (width < smallWidth) {
      hPadding *= 0.75; // 75% du padding normal
    }

    // Réduire le padding vertical sur écrans courts
    if (height < shortHeight) {
      vPadding *= 0.75; // 75% du padding normal
    }

    return EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding);
  }

  /// Retourne un espacement adaptatif (SizedBox height)
  static double getAdaptiveSpacing(
    BuildContext context, {
    required double base,
  }) {
    final height = MediaQuery.of(context).size.height;

    // Réduire l'espacement sur écrans courts
    if (height < shortHeight) {
      return base * 0.7; // 70% de l'espacement normal
    }

    return base;
  }

  /// Retourne une taille d'icône adaptative
  static double getAdaptiveIconSize(
    BuildContext context, {
    required double base,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Réduire sur très petits écrans ou écrans courts
    if (width < smallWidth || height < shortHeight) {
      return base * 0.85; // 85% de la taille normale
    }

    return base;
  }

  /// Retourne une hauteur maximale adaptative pour dialogs/modals
  static double getAdaptiveMaxHeight(
    BuildContext context, {
    double factor = 0.8,
  }) {
    final height = MediaQuery.of(context).size.height;
    return height * factor;
  }
}
