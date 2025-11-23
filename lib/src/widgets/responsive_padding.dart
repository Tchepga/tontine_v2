import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Widget qui applique des paddings adaptatifs selon la largeur ET la hauteur de l'écran
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets finalPadding;

    if (padding != null) {
      // Si padding est fourni, l'adapter
      finalPadding = ResponsiveHelper.getAdaptivePadding(
        context,
        horizontal: padding!.horizontal,
        vertical: padding!.vertical,
      );
    } else if (all != null) {
      // Si all est fourni, utiliser pour tous les côtés
      finalPadding = ResponsiveHelper.getAdaptivePadding(context, all: all);
    } else {
      // Construire le padding à partir des valeurs individuelles
      final hPadding = horizontal ?? left ?? right ?? 16.0;
      final vPadding = vertical ?? top ?? bottom ?? 16.0;

      finalPadding = ResponsiveHelper.getAdaptivePadding(
        context,
        horizontal: horizontal ??
            (left != null && right != null ? (left! + right!) / 2 : hPadding),
        vertical: vertical ??
            (top != null && bottom != null ? (top! + bottom!) / 2 : vPadding),
      );

      // Appliquer les valeurs spécifiques si fournies
      if (top != null || bottom != null || left != null || right != null) {
        finalPadding = EdgeInsets.only(
          top: top ?? finalPadding.top,
          bottom: bottom ?? finalPadding.bottom,
          left: left ?? finalPadding.left,
          right: right ?? finalPadding.right,
        );
      }
    }

    return Padding(
      padding: finalPadding,
      child: child,
    );
  }
}

/// Widget qui applique un espacement vertical adaptatif
class ResponsiveSpacing extends StatelessWidget {
  final double height;

  const ResponsiveSpacing({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final adaptiveHeight = ResponsiveHelper.getAdaptiveSpacing(
      context,
      base: height,
    );
    return SizedBox(height: adaptiveHeight);
  }
}
