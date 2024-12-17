import 'package:flutter/material.dart';
import '../screen/dashboard_view.dart';
import '../screen/casflow/cashflow_view.dart';
import '../screen/member/account_view.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on),
          label: 'Trésorerie',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Compte',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, DashboardView.routeName);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, CashflowView.routeName);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AccountView.routeName);
            break;
        }
      },
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
