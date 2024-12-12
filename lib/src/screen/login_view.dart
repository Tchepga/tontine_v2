import 'package:flutter/material.dart';
import 'package:tontine_v2/src/screen/dashboard_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Builder(
          builder: (context) => Column(
            children: [
              const SizedBox(height: 100),
              Text(
                'Connectez-vous',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nom d\'utilisateur',
                ),
              ),
              const SizedBox(height: 40),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mot de passe',
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        content: Text('Connexion réussie'),
                      ),
                    );
                    Navigator.pushNamed(context, DashboardView.routeName);
                  },
                  child: const Text(
                    'Connectez-vous',
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.indigoAccent,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
