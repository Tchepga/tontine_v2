import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/models/enum/currency.dart';
import '../providers/auth_provider.dart';
import '../providers/tontine_provider.dart';
import '../widgets/menu_widget.dart';
import 'casflow/cashflow_view.dart';
import 'loan/loan_view.dart';
import 'login_view.dart';
import 'rapport/rapport_view.dart';
import 'tontine/select_tontine_view.dart';
import 'tontine/setting_tontine_view.dart';
import 'event/event_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  static const routeName = '/dashboard';
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const withBlock = 180.0;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine == null) {
        Navigator.of(context).pushReplacementNamed(SelectTontineView.routeName);
      }
    });
  }

  void navigateToView(context, String route) {
    Navigator.pushNamed(context, route);
  }

  static const notifications = [
    {
      'title': 'Rapport Tontine',
      'subtitle': 'View the details of the tontine meetings.',
      'route': RapportView.routeName,
    },
    {
      'title': 'Cash Flow',
      'subtitle': 'View the cash flow of the tontine.',
      'route': RapportView.routeName,
    },
    {
      'title': 'Rapport Tontine',
      'subtitle': 'View the details of the tontine meetings.',
      'route': RapportView.routeName,
    },
    {
      'title': 'Cash Flow',
      'subtitle': 'View the cash flow of the tontine.',
      'route': RapportView.routeName,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TontineProvider>(
      builder: (context, authProvider, tontineProvider, child) {
        if (authProvider.isLoading || tontineProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentTontine = tontineProvider.currentTontine;
        final cashFlowAmount = currentTontine?.cashFlow.amount ?? 0.0;
        final currency = currentTontine?.cashFlow.currency.displayName;

        if (currentTontine == null) {
          return const Scaffold(
            body: Center(
              child: Text('Aucune tontine sélectionnée'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue[400],
              actions: [
                IconButton(
                  iconSize: 30.0, // Increase the size of the button
                  color: Colors.white,
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    print('Notifications');
                  },
                ),
                IconButton(
                  iconSize: 30.0, // Increase the size of the button
                  icon: const Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, SettingTontineView.routeName);
                  },
                ),
                IconButton(
                  iconSize: 30.0, // Increase the size of the button
                  icon: const Icon(Icons.power_settings_new),
                  color: Colors.white,
                  onPressed: () {
                    authProvider.logout();
                    Navigator.of(context)
                        .pushReplacementNamed(LoginView.routeName);
                  },
                ),
              ],
            ),
            body: ListView(
              children: [
                SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        margin: const EdgeInsets.all(10.0),
                        child: Stack(
                          children: [
                            Container(
                              width: 300.0,
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['title']!,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    notification['subtitle']!,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      navigateToView(
                                          context, notification['route']!);
                                    },
                                    child: const Text('View'),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  // Handle close button press
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30.0),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Etat de la trésorerie',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.blue[400]!),
                              shape: WidgetStatePropertyAll<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            onPressed: () {
                              navigateToView(context, CashflowView.routeName);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Solde actuel',
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white)),
                                  Text('$cashFlowAmount $currency',
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            )),
                        const SizedBox(height: 30.0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FilledButton(
                                style: ButtonStyle(
                                  minimumSize: WidgetStatePropertyAll<Size>(
                                    Size(
                                        MediaQuery.of(context).size.width * 0.4,
                                        60),
                                  ),
                                  backgroundColor:
                                      const WidgetStatePropertyAll<Color>(
                                          Colors.orangeAccent),
                                  shape: WidgetStatePropertyAll<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  navigateToView(context, LoanView.routeName);
                                },
                                child: const Text('Prêts'),
                              ),
                              FilledButton(
                                style: ButtonStyle(
                                  minimumSize: WidgetStatePropertyAll<Size>(
                                    Size(
                                        MediaQuery.of(context).size.width * 0.4,
                                        60),
                                  ),
                                  shape: WidgetStatePropertyAll<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  navigateToView(
                                      context, RapportView.routeName);
                                },
                                child: const Text('Rapports'),
                              ),
                            ]),
                        const SizedBox(width: 10.0),
                        Expanded(child: EventView())
                      ],
                    ))
              ],
            ),
            bottomNavigationBar: const MenuWidget(),
          );
        }
      },
    );
  }

  

  
}
