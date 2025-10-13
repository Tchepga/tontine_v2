import 'package:flutter/material.dart';

import '../screen/casflow/cashflow_view.dart';
import '../screen/event/event_view.dart';
import '../screen/member/account_view.dart';
import '../screen/member/member_view.dart';
import '../screen/dashboard_view.dart';
import '../theme/app_theme.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
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
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'menu_fab',
              backgroundColor: AppColors.primary,
              elevation: 4,
              onPressed: () {
                Navigator.pushNamed(context, DashboardView.routeName);
              },
              child: const Icon(Icons.dashboard, color: Colors.white, size: 32),
            ),
          ),
          // Icône Cashflow à gauche
          Positioned(
            left: 24,
            bottom: 18,
            child: IconButton(
              icon: const Icon(Icons.balance, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, CashflowView.routeName);
              },
            ),
          ),
          // Icône Members (gestion des membres)
          Positioned(
            left: 80,
            bottom: 18,
            child: IconButton(
              icon: const Icon(Icons.people, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, MemberView.routeName);
              },
            ),
          ),
          // Icône Events
          Positioned(
            right: 80,
            bottom: 18,
            child: IconButton(
              icon: const Icon(Icons.event_available,
                  color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, EventView.routeName);
              },
            ),
          ),
          // Icône Account à droite
          Positioned(
            right: 24,
            bottom: 18,
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 28),
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
