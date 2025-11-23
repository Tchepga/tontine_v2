import 'package:flutter/material.dart';

import '../screen/casflow/cashflow_view.dart';
import '../screen/event/event_view.dart';
import '../screen/member/account_view.dart';
import '../screen/member/member_view.dart';
import '../screen/dashboard_view.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Hauteur adaptative selon la hauteur de l'écran
    final menuHeight = ResponsiveHelper.getAdaptiveHeightValue(
      context,
      short: 70.0,
      medium: 80.0,
      tall: 80.0,
    );

    // Taille des icônes adaptative
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(
      context,
      base: 28.0,
    );

    final fabIconSize = ResponsiveHelper.getAdaptiveIconSize(
      context,
      base: 32.0,
    );

    // Calcul des positions adaptatives selon la largeur
    double leftPosition1, leftPosition2, rightPosition1, rightPosition2;
    double bottomPosition;

    if (width < ResponsiveHelper.smallWidth) {
      // Très petits écrans : positions plus serrées
      leftPosition1 = 12.0;
      leftPosition2 = 60.0;
      rightPosition1 = 60.0;
      rightPosition2 = 12.0;
      bottomPosition = 14.0;
    } else if (width < ResponsiveHelper.mediumWidth) {
      // Écrans moyens : positions légèrement réduites
      leftPosition1 = 20.0;
      leftPosition2 = 70.0;
      rightPosition1 = 70.0;
      rightPosition2 = 20.0;
      bottomPosition = 16.0;
    } else {
      // Grands écrans : positions normales
      leftPosition1 = 24.0;
      leftPosition2 = 80.0;
      rightPosition1 = 80.0;
      rightPosition2 = 24.0;
      bottomPosition = 18.0;
    }

    // Ajuster bottomPosition selon la hauteur
    if (height < ResponsiveHelper.shortHeight) {
      bottomPosition *= 0.85; // Réduire sur écrans courts
    }

    // Position du FAB central
    final fabBottom = ResponsiveHelper.getAdaptiveHeightValue(
      context,
      short: 20.0,
      medium: 24.0,
      tall: 24.0,
    );

    return SizedBox(
      height: menuHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Fond arrondi
          Positioned.fill(
            child: CustomPaint(
              painter: _FooterPainter(),
            ),
          ),
          // Bouton central Dashboard
          Positioned(
            bottom: fabBottom,
            child: FloatingActionButton(
              heroTag: 'menu_fab',
              backgroundColor: AppColors.primary,
              elevation: 4,
              mini: width < ResponsiveHelper.smallWidth ||
                  height < ResponsiveHelper.shortHeight,
              onPressed: () {
                Navigator.pushNamed(context, DashboardView.routeName);
              },
              child:
                  Icon(Icons.dashboard, color: Colors.white, size: fabIconSize),
            ),
          ),
          // Icône Cashflow à gauche
          Positioned(
            left: leftPosition1,
            bottom: bottomPosition,
            child: IconButton(
              icon: Icon(Icons.balance, color: Colors.white, size: iconSize),
              onPressed: () {
                Navigator.pushNamed(context, CashflowView.routeName);
              },
            ),
          ),
          // Icône Members (gestion des membres)
          Positioned(
            left: leftPosition2,
            bottom: bottomPosition,
            child: IconButton(
              icon: Icon(Icons.people, color: Colors.white, size: iconSize),
              onPressed: () {
                Navigator.pushNamed(context, MemberView.routeName);
              },
            ),
          ),
          // Icône Events
          Positioned(
            right: rightPosition1,
            bottom: bottomPosition,
            child: IconButton(
              icon: Icon(Icons.event_available,
                  color: Colors.white, size: iconSize),
              onPressed: () {
                Navigator.pushNamed(context, EventView.routeName);
              },
            ),
          ),
          // Icône Account à droite
          Positioned(
            right: rightPosition2,
            bottom: bottomPosition,
            child: IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: iconSize),
              onPressed: () {
                Navigator.pushNamed(context, AccountView.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final path = Path();
    // Arrondi à gauche
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 30, 0);
    // Ligne jusqu'à avant le creux
    path.lineTo(size.width * 0.35, 0);
    // Début du creux circulaire
    path.cubicTo(
        size.width * 0.40,
        0, // contrôle gauche
        size.width * 0.42,
        40, // contrôle bas gauche
        size.width * 0.50,
        40 // point bas du creux
        );
    path.cubicTo(
        size.width * 0.58,
        40, // contrôle bas droite
        size.width * 0.60,
        0, // contrôle droite
        size.width * 0.65,
        0 // sortie du creux
        );
    // Ligne jusqu'à l'arrondi droit
    path.lineTo(size.width - 30, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    // Descend sur le bord droit
    path.lineTo(size.width, size.height);
    // Ligne bas
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
