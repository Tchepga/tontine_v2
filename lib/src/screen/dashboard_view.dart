import 'package:flutter/material.dart';
import 'package:tontine_v2/src/screen/casflow/cashflow_view.dart';
import 'package:tontine_v2/src/screen/rapport_view.dart';
import 'package:tontine_v2/src/widgets/menu_widget.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import 'login_view.dart';
import 'services/member_service.dart';
import '../providers/auth_provider.dart';
import '../providers/tontine_provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  static const routeName = '/dashboard';
  static const withBlock = 180.0;
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _memberService = MemberService();
  Member? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
      
      // Charger les données
      await Future.wait([
        authProvider.loadProfile(),
        tontineProvider.loadTontines(),
      ]);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement des données'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushReplacementNamed(LoginView.routeName);
    }
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

  static const cashFlowAmout = 50000.0;

  get firstDate => null;

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

        // final user = authProvider.currentUser;
        // final tontines = tontineProvider.tontines;

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
                icon: const Icon(Icons.power_settings_new),
                color: Colors.white,
                onPressed: () {
                  print('Logout');
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
                                    navigateToView(context, notification['route']!);
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
                            backgroundColor:
                                WidgetStatePropertyAll<Color>(Colors.blue[400]!),
                            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            navigateToView(context, CashflowView.routeName);
                          },
                          child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Solde actuel',
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white)),
                                  Text('$cashFlowAmout Fcfa',
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ))),
                      const SizedBox(height: 30.0),
                      CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2200),
                        onDateChanged: (date) {
                          print(date);
                        },
                      )
                    ],
                  ))
            ],
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }
}
