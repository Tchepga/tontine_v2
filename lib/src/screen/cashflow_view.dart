import 'package:flutter/material.dart';

class CashflowView extends StatelessWidget{
  const CashflowView({Key? key}) : super(key: key);
  static const routeName = '/cashflow';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Trésorerie'),
        ),
      body:  ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).secondaryHeaderColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: const Center(
              child: Column(
                children: [
                  Text(
                    '20000 EUR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  ),
                  Text(
                    'Solde actuel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Historique',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}